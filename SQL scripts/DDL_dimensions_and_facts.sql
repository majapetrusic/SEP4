-- date

		 DROP TABLE d_date;
  DROP sequence sq_date;
 
  CREATE SEQUENCE sq_date START WITH 1 INCREMENT BY 1 NOMAXVALUE CACHE 20 ;
  CREATE TABLE d_date
    (
      id    NUMBER CONSTRAINT dDatePK PRIMARY KEY,
      YEAR  INTEGER NOT NULL CHECK (YEAR                   > 0),
      MONTH INTEGER NOT NULL CHECK (MONTH                  > 0
    AND MONTH                                             <= 12),
      DAY  INTEGER NOT NULL CHECK (DAY                     > 0),
      hour INTEGER NOT NULL CHECK (hour                   >= 0
    AND hour                                              <= 24),
      minute INTEGER NOT NULL CHECK (minute               >= 0
    AND minute                                            <= 59),
      month_name  VARCHAR2(3) CHECK (month_name  IN ('JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC')),
      week_number INTEGER CHECK (week_number      > 0
    AND week_number                                       <= 53),
     
      day_of_week   VARCHAR2(3) CHECK (day_of_week IN ('MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN')),
      season        VARCHAR2(6) CHECK (season      IN ('SPRING', 'SUMMER', 'AUTUMN', 'WINTER')),
      CONSTRAINT coUniqueDate UNIQUE (YEAR,MONTH,DAY,hour,minute)
    )
    PCTFREE 0;
	
-- F_WEATHER	
CREATE SEQUENCE sq_weather START WITH 1 INCREMENT BY 1 NOMAXVALUE;

create table f_weather(
date_id NUMBER NOT NULL REFERENCES d_date(id), 
dew_point_temperature number NOT NULL,
surface_temperature number NOT NULL,
cloud_cover number NOT NULL,
cloud_cover_name VARCHAR(60) NOT NULL,
wind_direction number NOT NULL,
win_speed_in_knots number NOT NULL,
issuing_airport VARCHAR(20) NOT NULL
) pctfree 0;


--d_ flight
CREATE SEQUENCE sq_flight START WITH 1 INCREMENT BY 1 NOMAXVALUE;

--We realized that the flight needed to have a dimension
--so that it can be connected to more facts about the flight
CREATE TABLE d_flight(
id NUMBER NOT NULL CONSTRAINT dFlightPK PRIMARY KEY,
log_name VARCHAR(20)
)pctfree 0;


--d_grid
CREATE SEQUENCE sq_grid START WITH 1 INCREMENT BY 1 NOMAXVALUE;

create table d_grid(
  id NUMBER NOT NULL CONSTRAINT dGridPK PRIMARY KEY ,
  start_latitude NUMBER NOT NULL,
  end_latitude NUMBER NOT NULL,
  start_longitude NUMBER NOT NULL,
  end_longitude NUMBER NOT NULL
) pctfree 0;

CREATE SEQUENCE sq_thermal START WITH 1 INCREMENT BY 1 NOMAXVALUE;

create table f_thermal(
  date_found_id NUMBER NOT NULL REFERENCES d_date(id),
  flight_id NUMBER NOT NULL REFERENCES d_flight(id),
  grid_id NUMBER NOT NULL REFERENCES d_grid(id),
  valid_to date not null
) pctfree 0;




  
--------REST OF THE DDL (THE SAME AS THE DWH COURSE PROJECT)------------
  
  -- member
  
  DROP TABLE d_member;
  DROP sequence sq_member;
  
  CREATE SEQUENCE sq_member START WITH 1 INCREMENT BY 1 NOMAXVALUE CACHE 20 ;
  CREATE TABLE d_member
    (
      id         NUMBER NOT NULL CONSTRAINT dMemberPK PRIMARY KEY ,
      member_no  NUMBER  ,
      initials   CHAR(4) NOT NULL,
      name       VARCHAR (50) NOT NULL,
      sex        CHAR(01) NOT NULL CONSTRAINT coMbSex CHECK (sex IN ('M', 'F')) ,
      zip_code   INTEGER NOT NULL,
      address    VARCHAR (80) NOT NULL,
      date_born  DATE NOT NULL,
      status     VARCHAR (20) NOT NULL,
      valid_from DATE NOT NULL,
      valid_to   DATE NOT NULL
    )
    PCTFREE 0;

	-- club
	DROP TABLE d_club;
  DROP sequence sq_club;
  
  CREATE SEQUENCE sq_club START WITH 1 INCREMENT BY 1 NOMAXVALUE CACHE 20;
  CREATE TABLE d_club
    (
      id          NUMBER NOT NULL CONSTRAINT dClubPK PRIMARY KEY,
      name VARCHAR2(50) NOT NULL,
	  region_name VARCHAR2(50) NOT NULL,
      address     VARCHAR2(80) NOT NULL,
      zip_code    INTEGER CONSTRAINT coCheckZipCode CHECK ( zip_code > 0 ),
      valid_from  DATE NOT NULL,
      valid_to    DATE NOT NULL
    )
    PCTFREE 0;
  
	-- plane 
	
  	drop SEQUENCE sq_plane;
    drop TABLE d_plane;
  
  
	CREATE SEQUENCE sq_plane START WITH 1 INCREMENT BY 1 NOMAXVALUE CACHE 20;
  CREATE TABLE d_plane
    (
      
	id             NUMBER NOT NULL CONSTRAINT dAirplanePK PRIMARY KEY ,
	 registration_no          VARCHAR2(10) NOT NULL,     
	 class_name          VARCHAR2(20) NOT NULL,
      class_description   VARCHAR2(20) NOT NULL,
      has_engine           CHAR(1) DEFAULT 'N' NOT NULL CONSTRAINT coCheckEngine CHECK (has_engine    IN ('Y','N')),
      number_of_seats     SMALLINT DEFAULT 1 NOT NULL CONSTRAINT coCheckNumberOfSeats CHECK (number_of_seats IN (1, 2)),
      competition_number  VARCHAR2(10) NOT NULL,
      valid_from          DATE NOT NULL,
      valid_to            DATE NOT NULL
    )
    PCTFREE 0;
	
	--launch_method
	
	DROP TABLE d_launch_method;
  DROP sequence sq_launch_method;
  
  CREATE SEQUENCE sq_launch_method START WITH 1 INCREMENT BY 1 NOMAXVALUE CACHE 20;
  CREATE TABLE d_launch_method
    (
      id         NUMBER NOT NULL CONSTRAINT dLaunchMethodPK PRIMARY KEY,
      name       VARCHAR2(20) NOT NULL,
      cablebreak CHAR(1) DEFAULT 'N' NOT NULL CONSTRAINT coCheckCablebreak CHECK(cablebreak IN ('Y','N'))
    )
    PCTFREE 0;
	
	--age
  DROP TABLE d_age;
  DROP sequence sq_age;
	
  CREATE SEQUENCE sq_age START WITH 1 INCREMENT BY 1 NOMAXVALUE CACHE 20;
  CREATE TABLE d_age
    (
      id  NUMBER NOT NULL CONSTRAINT dAgePK PRIMARY KEY,
      age INTEGER NOT NULL CONSTRAINT coCheckAge CHECK (age > 0 AND age < 999)
    )
    PCTFREE 0;
	
	
	-- audit

  DROP TABLE d_audit;
  DROP sequence sq_audit;
  
  CREATE SEQUENCE sq_audit START WITH 1 INCREMENT BY 1 NOMAXVALUE;
    CREATE TABLE d_audit
    (
      id NUMBER NOT NULL,
      audit_date DATE NOT NULL,
      thermal_rejected NUMBER,
      thermal_fixed NUMBER,
      plane_rejected NUMBER,
      plane_fixed NUMBER,
      flight_rejected NUMBER,
      flight_fixed NUMBER,
      member_rejected NUMBER,
      member_fixed NUMBER,
      club_rejected NUMBER,
      club_fixed NUMBER,
      CONSTRAINT coUniqueDate1 UNIQUE(audit_date),
      CONSTRAINT dAuditPK PRIMARY KEY (id)
    )
    PCTFREE 0;
	
	-- bridge table

	DROP TABLE b_member_flight;
  DROP sequence sq_bridge_mf;
	
      
CREATE SEQUENCE sq_bridge_mf START WITH 1 INCREMENT BY 1 NOMAXVALUE CACHE 20 ;
  CREATE TABLE b_member_flight
    (
      group_id     NUMBER NOT NULL,
      pilot_id     NUMBER NOT NULL REFERENCES d_member(id),
      pilot_age_id NUMBER NOT NULL REFERENCES d_age(id),
	 weight      NUMBER NOT NULL constraint coCheckWeight CHECK (weight IN (1, 0.5)),
      CONSTRAINT bridge_mfPK PRIMARY KEY (group_id, pilot_id)
    )
    PCTFREE 0;
  
  -- fact flight 
  
 DROP TABLE f_flight;
  CREATE TABLE f_flight
    (
		flight_id NUMBER NOT NULL REFERENCES d_flight(id), --references the d_flight that only has the id
      launch_time_id   NUMBER NOT NULL REFERENCES d_date (id),
      landing_time_id  NUMBER NOT NULL REFERENCES d_date (id),
      launch_method_id NUMBER NOT NULL REFERENCES d_launch_method (id),
      plane_id      NUMBER NOT NULL REFERENCES d_plane (id),
      club_id   NUMBER NOT NULL REFERENCES d_club (id),
      group_id   NUMBER NOT NULL, -- references b_member_flight(group_id),
      distance NUMBER NOT NULL CHECK (distance >= 0),
      duration         NUMBER NOT NULL CHECK (duration         >= 0),
      CONSTRAINT fFlightPK PRIMARY KEY (launch_time_id,landing_time_id,launch_method_id,plane_id,club_id,group_id)
    )PCTFREE 0;
	
	-- fact ownership
	
 DROP TABLE f_ownership;
  DROP sequence sq_ownership;
 
CREATE SEQUENCE sq_ownership START WITH 1 INCREMENT BY 1 NOMAXVALUE CACHE 20 ;
  CREATE TABLE f_ownership
    (
      member_id   NUMBER REFERENCES d_member(id),
      club_id     NUMBER REFERENCES d_club(id),
      plane_id NUMBER NOT NULL REFERENCES d_plane(id),
      end_date    NUMBER NOT NULL REFERENCES d_date(id),
      start_date  NUMBER NOT NULL REFERENCES d_date(id),
      CONSTRAINT fOwnershipPK PRIMARY KEY (plane_id,club_id, member_id)
    )PCTFREE 0;

 -- fact membership
 
  drop SEQUENCE sq_membership  ;
  drop TABLE f_membership ;
 
 CREATE SEQUENCE sq_membership START WITH 1 INCREMENT BY 1 NOMAXVALUE CACHE 20 ;
  CREATE TABLE f_membership
    (
      club_id    NUMBER NOT NULL REFERENCES d_club(id),
      member_id  NUMBER NOT NULL REFERENCES d_member(id),
      leave_date NUMBER NOT NULL REFERENCES d_date(id),
      join_date  NUMBER NOT NULL REFERENCES d_date(id),
      CONSTRAINT dMembershipPK PRIMARY KEY (club_id,member_id)
    )PCTFREE 0;
 