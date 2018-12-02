--Populate d_flight


/* --------------------------------------------------- */
/*   ETL-D_FlightExtract                                  */
/* --------------------------------------------------- */
/* extracts added, deleted and changed rows from the   */
/* flight (source) table                              */
/*                                                     */
/* --------------------------------------------------- */


--OPTION 1: (FIRST TIME) The following queries are to create the flightToday and 
--flightYesterday tables for the first time

/*Create table with the current flights information*/
DROP TABLE flightToday;
CREATE TABLE flightToday AS
SELECT 
id as source_id,
flight_id AS log_name
FROM flight
WHERE id IN (
  SELECT MAX(id) FROM flight GROUP BY flight_id
);


/* Creating a yesterday table WHERE 1 = 0 used to create a table of identical structure, without data*/
/*because the first day of populating data will be considered as today and there is no yesterday*/
drop table flightYesterday;
create table flightYesterday 
as select * from flightToday where 1=0;



-- --------------------------------------------
-- pre-extract report
-- --------------------------------------------

--OPTION 2: The following queries are to USE FROM THE SECOND DAY - NOT FIRST TIME
/*Procedure to make before extracting on each day  
1. Delete yesterday's yesterday table and fill it with yesterday's today table
*/
drop table flightYesterday;
create table flightYesterday 
as select * from flightToday;

/*2. Delete yesterday's today table and update today table*/
DROP TABLE flightToday;
CREATE TABLE flightToday AS
SELECT 
id as source_id,
flight_id AS log_name
FROM flight
WHERE id IN (
  SELECT MAX(id) FROM flight GROUP BY flight_id
);

/*Empty the ETLFlightsExtractTable*/
drop table ETLFlightsExtract;
create table ETLFlightsExtract 
as select * from flightToday where 1=0;


--Make a pre-extract report
select 'Extract Flights at: ' || to_char(sysdate,'YYYY-MM-DD HH24:MI') as extractTime
  from dual
  ;

  select 'Row counts before: '
    from dual
union all
  select 'Rows in extract table before (should be zero)' || to_char(count(*))
   from ETLFlightsExtract
union all
  select 'Rows in Flights table ' || to_char(count(*))
   from Flight
union all
  select 'Rows in Fligths table (yesterday copy) ' || to_char(count(*))
   from flightYesterday
 ;



-- --------------------------------------------
-- extract procedure
-- --------------------------------------------

-- **** here goes the extract of added rows 
-- **** (i.e. rows from today whose primary key is in the set of (PKs from today minus PKs yesterday)
/*Create NEW  - all the rows that haven't been there Yesterday*/
DROP TABLE newFlight;
CREATE TABLE newFlight AS
    SELECT *
    FROM flightToday
    WHERE flightToday.source_id NOT IN
  ( SELECT source_id FROM flightYesterday);


-- insert in ETLextract to see the extracted new,changed and deleted rows

INSERT INTO  ETLFlightsExtract
SELECT * FROM newFlight;

commit;


-- --------------------------------------------
-- post-extract report
-- --------------------------------------------

select 'Rows in extract table after'
 from dual
;

select  count(*)
from ETLFlightsExtract
 ; 
 select * from ETLFlightsExtract;
 
 -------==============--TRANSFORMATION--============================
 
 /*Validation part*/
 
 /*We declare variables to count all the fixed rows plus some flags or booleans
 that will help us decide if we need to count or ignore the rows*/
DECLARE
  noOfFixedRows           NUMBER(1)  := 0;
  flagForFixedRows        NUMBER(1)  :=0;
  BEGIN
  /*Search for rows that have null for log_name and fix them*/
 
/*Starting with newMembers, check all rows*/
  FOR row IN
  (SELECT * FROM newFlight
  )
  LOOP
  /*set the variable of fixed Rows to 0 for each row checked*/
    flagForFixedRows := 0;
   
   /*Fix invalid log_name*/
    /*We fix log_name null with a string called unknown*/
    If row.log_name IS NULL THEN
        flagForFixedRows := 1;
        row.log_name := 'Unknown';
    END IF;

    /*We update the current row in newMember*/
    UPDATE newFlight
    SET log_name            = row.log_name
     WHERE source_id = row.source_id;
	
	/*Update the numberOfFixedRows if this row was fixed*/
	if flagForFixedRows = 1 then
	noOfFixedRows := noOfFixedRows+1;
	end if;
  END LOOP;

  /*Insert the counts for rejected and fixed rows in the audit*/
  INSERT
  INTO d_audit
    (
      id,
      audit_date,
      flight_fixed
    )
    VALUES
    (
      sq_audit.nextval,
      SYSDATE,
      noOfFixedRows
    );
  COMMIT;
END;
/

/*-----------Transformation for the member status------------*/
/*Creating a new table for the transformed member for both new and altered*/
drop table transformedNewFlight;
CREATE TABLE transformedNewFlight AS 
    (SELECT source_id, 
           log_name
           FROM newFlight where 0=1
    );

------=============================================================----------

/*Load data into the transformedNewFlights tables with transformed data*/
BEGIN
    /* transform all the rows newmember, set status */
  for row in (select * from newFlight) 
  LOOP
   
	--insert validated information plus the status name
    INSERT INTO transformedNewFlight (
       source_id,
       log_name
    )
    VALUES (
        row.source_id, 
        row.log_name 
    );
  END LOOP;
  COMMIT;
END;
/
--========================================================================
/*Now the information has been transformed and it is ready to be added to the dimension d_flight*/
BEGIN
 
  FOR row IN
  (SELECT * FROM transformedNewFlight
  )
  LOOP
  
  --for each flight we insert all the transformed information,
    INSERT
    INTO d_flight
      (
        id,
        log_name
      )
      VALUES
      (
       sq_flight.nextval,
        row.log_name
      );
  END LOOP;
  COMMIT;
END;
/
