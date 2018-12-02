--ETL FOR F_WEATHER

-- drop table yesterday weather
drop table yesterdayWeather;

--create table yesterday weather to store a copy of our weather data
create table yesterdayWeather as select * from weatherToday where 1=0;
insert into yesterdayWeather(select * from weatherToday);

/*Create table with the current weather information*/
DROP TABLE weatherToday;
CREATE TABLE weatherToday AS SELECT * FROM weather;


-- Search for the rows that were not in the yesterday table
DROP TABLE newWeather;

CREATE TABLE newWeather AS
  Select * from weatherToday 
 MINUS
  SELECT * from yesterdayWeather;

ALTER TABLE NEWWEATHER ADD (CLOUDCOVERNAME VARCHAR2(15));
-------------------validation part

--to keep up with changes

--We declare variables to save the values for each row in a loop, and some flags to keep the audit updated

declare
  currentDate DATE := SYSDATE;
  surface_temperature NUMBER;
  cloud_cover_temp varchar(6);
  temp_cloudcovername VARCHAR2(50);
  CLOUDCOVER NUMBER;

-- check the weather information

BEGIN
    FOR c IN (select* from newweather)
    LOOP

    /*if the weather date is in the future, delete weather*/
    if (c.DATE_TIME > currentDate) THEN
      delete from newWeather
      where id =c.id;
      end if;
    -- if the temperature is lower than the lowest possible physical value
    if (c.surface_temperature < -273.5) THEN
	   delete from newWeather  where id =c.id;
       end if;
     --Because all records are done after 2014, we can validate the flight accordingly
            IF (EXTRACT(YEAR FROM c.DATE_TIME) < 2014)
            THEN
            delete from newWeather  where id =c.id;
            END IF;
            
   -- separating the cloud cover information 
   cloud_cover_temp := c.cloud_Cover;
        cloudCover := SUBSTR(cloud_cover_temp, 4, 6);
        temp_cloudCoverName := SUBSTR(cloud_cover_temp, 0, 3);


        update newWeather set
        id = c.id,
        pressure = c.pressure,
        DEW_POINT_TEMPERATURE = c.DEW_POINT_TEMPERATURE,
        SURFACE_TEMPERATURE=c.SURFACE_TEMPERATURE,
        CLOUD_COVER=cloudCover, 
        VISIBILITY= c.VISIBILITY,
        ISSUING_AIRPORT=c.ISSUING_AIRPORT,
        WIND_DIRECTION=c.WIND_DIRECTIOn ,
        WIND_SPEED= c.WIND_SPEED,
        DATE_TIME=c.DATE_TIME,
        CLOUDCOVERNAME= temp_cloudCoverName
        where id = c.id;

end loop;
commit;
end;

  /*Creating a new empty table for the transformed weather the same columns as newWeather*/
drop table transformedWeather;

CREATE TABLE transformedWeather AS
  (SELECT * FROM newWeather where 0=1) ;


/*Loading data into the transformedWeather with the transformed data*/
--declaring variables to use for each row
DECLARE
  cloud_Cover_Name varchar2(20);
  ID NUMBER;
  cloud_Cover NUMBER;
  DATE_ID NUMBER;


BEGIN
  for row in (select * from newWeather)
  LOOP

  IF ROW.CLOUDCOVERNAME = 'FEW' THEN
  cloud_Cover_Name := 'light clouds';
  end if;
  --identify the cloud cover codes
    IF ROW.CLOUDCOVERNAME = 'BKN'  THEN
      cloud_Cover_Name := 'broken sky';

    ELSIF ROW.CLOUDCOVERNAME= 'SCT'  THEN
      cloud_Cover_Name := 'scatterd';

    ELSIF ROW.CLOUDCOVERNAME = 'FEW' THEN
      cloud_Cover_Name := 'few clouds';

    ELSIF
      ROW.CLOUDCOVERNAME = 'OVC' THEN
      cloud_Cover_Name := 'overcast';

    END IF;


--get the d_date id with the same date_found value
  BEGIN
    SELECT id into date_id from d_date
      where (
        year = extract (year from row.date_time) AND
        month = extract (month from row.date_time) AND
        day = extract (day from row.date_time) AND
        hour = to_number(to_char(row.date_time,'HH24'),'00') AND
        minute = to_number(to_char(row.date_time,'MI'),'00')
        );
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          select id into date_id from d_date where id=-1;
   end;
   commit;


INSERT INTO TRANSFORMEDWEATHER (id, PRESSURE, DEW_POINT_TEMPERATURE, SURFACE_TEMPERATURE, CLOUD_COVER, VISIBILITY, ISSUING_AIRPORT, WIND_DIRECTION, WIND_SPEED, CLOUDCOVERNAME)
VALUES (DATE_ID, row.PRESSURE, ROW.DEW_POINT_TEMPERATURE, ROW.SURFACE_TEMPERATURE, ROW.CLOUD_COVER, row.visibility,ROW.issuing_airport, ROW.WIND_DIRECTION, ROW.WIND_SPEED, cloud_Cover_Name);

end loop;
commit;
end;

insert into F_WEATHER(DATE_ID, DEW_POINT_TEMPERATURE, SURFACE_TEMPERATURE, CLOUD_COVER, WIND_DIRECTION, WIN_SPEED_IN_KNOTS, ISSUING_AIRPORT, CLOUD_COVER_NAME)
    select id, DEW_POINT_TEMPERATURE, SURFACE_TEMPERATURE, CLOUD_COVER, WIND_DIRECTION, WIND_SPEED, ISSUING_AIRPORT, CLOUDCOVERNAME from transformedWeather;
commit;
