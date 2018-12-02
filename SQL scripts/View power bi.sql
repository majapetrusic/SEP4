drop view sep_power_bi;


create view sep_power_bi as SELECT * FROM(
select GRID_ID ,F_THERMAL.VALID_TO, D_FLIGHT.LOG_NAME,
  D_DATE.YEAR, D_DATE.MONTH, D_DATE.day, D_DATE.HOUR, D_DATE.MINUTE, D_DATE.WEEK_NUMBER, D_DATE.DAY_OF_WEEK, D_DATE.SEASON,
  D.START_LATITUDE, D.END_LATITUDE, D.START_LONGITUDE, D.END_LONGITUDE,
  DEW_POINT_TEMPERATURE, SURFACE_TEMPERATURE, CLOUD_COVER, cloud_cover_name, WIND_DIRECTION, WIN_SPEED_IN_KNOTS, ISSUING_AIRPORT from F_THERMAL
  left outer join D_FLIGHT on F_THERMAL.FLIGHT_ID = D_FLIGHT.ID
  left outer JOIN D_DATE on F_THERMAL.DATE_FOUND_ID = D_DATE.ID
  left outer join D_GRID D on F_THERMAL.GRID_ID = D.ID
 --left outer join F_WEATHER on D_DATE.ID = F_WEATHER.DATE_ID;
left outer join (
  select DEW_POINT_TEMPERATURE, SURFACE_TEMPERATURE, CLOUD_COVER, cloud_cover_name, WIND_DIRECTION, WIN_SPEED_IN_KNOTS, ISSUING_AIRPORT,
  YEAR, MONTH, day from
   (select * from (
  select * from f_weather join d_date on f_weather.date_id = d_date.id where D_DATE.year =2018 AND d_date.day=12 AND D_DATE.month=05
  AND ROWNUM =1
  UNION
  select * from f_weather join d_date on f_weather.date_id = d_date.id where D_DATE.year =2018 AND d_date.day=11 AND D_DATE.month=05
  AND ROWNUM=1))) weather on 
  D_DATE.year = weather.year AND d_date.day=weather.day AND D_DATE.month=weather.month)
WHERE GRID_ID IN (select GRID_ID from (select GRID_ID, count (*) as number_of_thermals from F_THERMAL group by GRID_ID)
where number_of_thermals >= (select avg(number_of_thermals) from (
select GRID_ID, count (*) as number_of_thermals from F_THERMAL group by GRID_ID)
where number_of_thermals > 1));
  
  
  --Check the right amount with the following count the results should be the same.
  select count(log_name) from sep_power_bi;
  select count(flight_id) from f_thermal;

