--Declaring variables and initialize them
--to use in the begin-end procedure
--to populate all the dates once

--the date has as many columns as possible
--because then it is easier to make queries 
--or data analysis.

--currentDate and lastDate will be the interval of times
--in minutes that the d_date dimension will be 
--populated with.

declare
  currentDate date := to_date('2018-05-10','YYYY-MM-DD');
  lastDate  date := to_date('2018-05-13','YYYY-MM-DD');
  zyear      int := 0;
  zmonth     int := 0;
  zday       int := 0;
  zhour      int := 0;
  zminute    int := 0;
  zmonth_name char(3);
  zday_of_week char(3);
  zseason char(6);
  zweek_number int;
  
  oneMinute   interval day to second := to_dsinterval ('00 00:01:00');
begin

  while currentDate <= lastDate loop
     zyear := extract (year from currentDate);
     zmonth := extract (month from currentDate);
     zday := extract (day from currentDate);
     zhour := to_number(to_char(currentDate, 'HH24'), '00');
     zminute := to_number(to_char(currentDate, 'MI'), '00');
     zweek_number := to_number(to_char(currentDate, 'WW'), '00');
 
      SELECT CASE zmonth
          WHEN 1 THEN 'JAN'
          WHEN 2 THEN 'FEB'
          WHEN 3 THEN 'MAR'
          WHEN 4 THEN 'APR'
          WHEN 5 THEN 'MAY'
          WHEN 6 THEN 'JUN'
          WHEN 7 THEN 'JUL'
          WHEN 8 THEN 'AUG'
          WHEN 9 THEN 'SEP'
          WHEN 10 THEN 'OCT'
          WHEN 11 THEN 'NOV'
          WHEN 12 THEN 'DEC'
      END INTO zmonth_name
    FROM dual;
  
    SELECT CASE zmonth
          WHEN 1 THEN 'WINTER'
          WHEN 2 THEN 'WINTER'
          WHEN 3 THEN 'SPRING'
          WHEN 4 THEN 'SPRING'
          WHEN 5 THEN 'SPRING'
          WHEN 6 THEN 'SUMMER'
          WHEN 7 THEN 'SUMMER'
          WHEN 8 THEN 'SUMMER'
          WHEN 9 THEN 'AUTUMN'
          WHEN 10 THEN 'AUTUMN'
          WHEN 11 THEN 'AUTUMN'
          WHEN 12 THEN 'WINTER'
    END INTO zseason FROM dual;
    
    SELECT CASE to_char (currentDate, 'FmDay', 'nls_date_language=english')
          when 'Monday' then 'MON'
          when 'Tuesday' then 'TUE'
          when 'Wednesday' then 'WED'
          when 'Thursday' then 'THU'
          when 'Friday' then 'FRI'
          when 'Saturday' then 'SAT'
          ELSE 'SUN'
    END INTO zday_of_week FROM dual;
    
     INSERT INTO d_date(id, year, month, day, hour, minute, month_name, day_of_week, season, week_number)
     VALUES
     (sq_date.NEXTVAL, zyear, zmonth, zday, zhour, zminute, zmonth_name, zday_of_week, zseason, zweek_number);

     currentDate := currentDate + oneMinute;
       COMMIT;
  end loop;

end;
/