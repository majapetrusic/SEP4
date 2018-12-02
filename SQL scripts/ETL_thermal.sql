-- ETL FOR F_thermal


-- OPTION 1 : first time run -----do not run this from second time=================================
drop table thermalToday;
create table thermalToday 
as select * from thermal;

--empty yesterday cuse its the first time, there is no yesterday
drop table thermalsYesterday;
create table thermalsYesterday 
as select * from thermalToday where 1=0;

---------- OPTION 2: TO RUN from the 2nd day================and run from here every day

--Make a copy of all the flights from yesterday
drop table thermalsYesterday;
create table thermalsYesterday 
as select * from thermalToday;

--Copy of all the flights today
drop table thermalToday;
create table thermalToday 
as select * from thermal;



-- Search for the rows that were not in the yesterday table
DROP TABLE newThermals;

CREATE TABLE newThermals AS
  Select * from thermalToday 
  MINUS
  SELECT * from thermalsYesterday;
  
  
----------Validation of data-----------------------------------:

  --We declare variables to save the values for each row in a loop, and some flags to keep the audit updated
declare
  noOfFixedRows           NUMBER(1)  := 0;
  noOfNewRejectedRows NUMBER (1) := 0;
  row_fixed_flag NUMBER(1) := 0;
  row_deleted_flag NUMBER (1) := 0;
  currentDate DATE := SYSDATE;
  maxLat NUMBER := 0;
  minLat NUMBER := 0;
  maxLong NUMBER := 0;
  minLong NUMBER := 0;
  
  --We check all the new flights information
begin

  FOR row IN (SELECT * FROM newThermals)
  LOOP
  
   maxLat := row.MaxLatitude;
  minLat := row.minlatitude;
  maxLong := row.maxlongitude;
  minLong := row.minlongitude;
  
   /*if the date found is in the future, delete the thermal, set flag for deleted row*/
    if (row.date_found > currentDate) THEN 
      delete from newThermals where 
      ( id = row.id);
      row_deleted_flag := 1; 
    END IF;
	
	/*  we wont take into consideration thermals older than 5 years, and we also have not populated the d_date with
dates less than 2013, so we delete those thermals and set the flag	*/
    if (extract(year from row.date_found)<2013) THEN 
      delete from newThermals where 
      id = row.id;
      row_deleted_flag := 1;
     END IF;
	 
	 
    /* If the latitude or longitude values (>360, <0) are not valid we delete them set the flag*/
    	IF (row.MaxLatitude > 360)  OR (row.MaxLatitude < 0) or 
      (row.minlatitude > 360)  OR (row.minLatitude < 0) or
       (row.Maxlongitude > 360)  OR (row.Maxlongitude < 0) or 
        (row.minlongitude > 360)  OR (row.minlongitude < 0)
      THEN
      delete from newThermals where 
      id = row.id;
      row_deleted_flag := 1;
     END IF;
	 
    
    
      /* For the latitude: If the max value is smaller than the min value we swap them and set flag for fixed*/
	IF (row.MaxLatitude < row.minlatitude) 
      THEN
      minLat := maxLat;
      maxLat := row.minLatitude;
      row.maxlatitude := maxLat;
      row.minlatitude := minLat;
      row_fixed_flag := 1;
    END IF;
    
    /* For the latitude: If the max value is smaller than the min value we swap them and set flag for fixed*/
	IF (row.Maxlongitude < row.minlongitude) 
      THEN
      minLong := maxLong;
      maxLong := row.minLongitude;
      row.maxlongitude := maxLong;
      row.minlongitude := minLong;
      row_fixed_flag := 1;
    END IF;
    
    
   --------------------!!!! /*THE FOLLOWING VALIDATION IS ONLY FOR DENMARK!! */ !!!---------------------
  --------------WE CHECK IF THE LATITUDE VALUES WERE SWAPPED WITH LONGITUDE VALUES------
    	IF (row.MaxLatitude <= 15)  AND (row.MaxLatitude >= 6) AND 
      (row.minlatitude >= 6)  AND (row.minLatitude <= 15) AND
       (row.Maxlongitude <= 58)  AND (row.Maxlongitude >=54 ) AND
        (row.minlongitude >= 54)  AND (row.minlongitude <= 58)
         THEN
      minLong := row.minlatitude;
      maxLong := row.maxlatitude;
      row.maxlatitude := row.maxlongitude;
      row.minlatitude := row.minlongitude;
      row.maxlongitude := maxLong;
      row.minlongitude := minLong;
      row_fixed_flag := 1;
    END IF;

	--Update the fixed information for the newFlight
    UPDATE newThermals SET
     id = row.id,
      flight_id = row.flight_id,
      date_found = row.date_found,
      maxlatitude = row.maxlatitude,
      minlatitude = row.minlatitude,
      maxlongitude = row.maxlongitude,
      minlongitude = row.minlongitude
    where 
      id = row.id;
	  
	  
	  --Count the row if it was fixed or deleted 
	  	if row_fixed_flag = 1 then
	noOfFixedRows := noOfFixedRows+1;
	end if;
	  
	  if row_deleted_flag  = 1 then
	 noOfNewRejectedRows := noOfNewRejectedRows+1;
	 end if;
 
	   
  END LOOP;

commit;


  /*Insert the counts for rejected and fixed rows in the audit*/
  INSERT
  INTO d_audit
    (
      id,
      audit_date,
      thermal_rejected,
      thermal_fixed
    )
    VALUES
    (
      sq_audit.nextval,
      SYSDATE,
      noOfNewRejectedRows,
      noOfFixedRows
    );
  COMMIT;
end;
/


/*Creating a new empty table for the transformed thermals with the same columns as newThermals*/

drop table transformedThermals;

CREATE TABLE transformedThermals AS
  (SELECT flight_id AS log_name,
  date_found,
  maxlatitude,
  minlatitude,
  maxlongitude,
  minlongitude
    FROM newThermals
  ) ;
  
/*Loading the data to the dimension, we declare the variables that we will use in the loops for each row*/
DECLARE
  temp_date_id NUMBER;
  flight_id NUMBER;
  grid_id NUMBER;
  end_date DATE;
 
BEGIN
  FOR row IN (SELECT * FROM transformedThermals)
  LOOP
     
    --SEARCH THE d_flight ID IN THE flight DIMENSION WITH THE SAME log_name  
	--(CHOOSE THE FIRST RESULT IF THERE IS MORE THAN ONE flight WITH THE SAME log_name)
 BEGIN
    SELECT id into flight_id from d_flight 
      where log_name = row.log_name;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
		--IF NO d_flight WAS FOUND MATCH it with a FAKE flight
         select id into flight_id from d_flight where id=-1;
   END;
 
 --get the d_date id with the same date_found value 
  BEGIN
    SELECT id into temp_date_id from d_date
      where (
        year = extract (year from row.date_found) AND
        month = extract (month from row.date_found) AND
        day = extract (day from row.date_found) AND
        hour = to_number(to_char(row.date_found,'HH24'),'00') AND
        minute = to_number(to_char(row.date_found,'MI'),'00')
        );
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          select id into temp_date_id from d_date where id=111;
   END; 
 
      /*Searching for the grid_id with the respective latitudes and longitudes values*/
     begin
      select id into grid_id from d_grid
        where start_latitude < row.maxlatitude and end_latitude > row.minlatitude
        and start_longitude < row.maxLongitude and end_longitude > row.minlongitude
        and rownum < 2;
		--if theres no grid found match it with a fake one
          EXCEPTION
        When NO_DATA_FOUND THEN 
          select id into grid_id from d_grid where id=-1;
      end;
        
        
        --THE END_DATE WILL BE FIVE YEARS FROM NOW
		   SELECT add_months(SYSDATE, (12*5)) INTO end_date FROM dual;
       
       
---------------FINALLY LOADING THE DATA TO F_THERMAL WITH ALL THE TRANSFORMED VALUES----------------------
      insert into f_THERMAL 
      (
       DATE_FOUND_ID,
       FLIGHT_ID,
       GRID_ID,
       VALID_TO
      ) VALUES
      (
        temp_date_id,
        flight_id,
        grid_id,
       END_DATE
      );

  END LOOP;
  commit;
END;
--The end :)

