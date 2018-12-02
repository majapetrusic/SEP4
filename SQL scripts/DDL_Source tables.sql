drop table  flight;
drop table  weather;
drop sequence idFlightSequence;
drop sequence idWeatherSequence;

create table FLIGHT
(
  ID                 NUMBER                      not null
    constraint FLIGHT_ID
    primary key,
  FLIGHT_ID          VARCHAR2(15)                not null,
  GPS_ALTITUDE       NUMBER                      not null,
  PRESSURE_ALTITUDE  NUMBER                      not null,
  SATELLITE_COVERAGE VARCHAR2(1)                 not null,
  POSITION_LONGITUDE VARCHAR2(20)                not null,
  POSITION_LATITUDE  VARCHAR2(20)                not null,
  LOG_TIME           TIMESTAMP(6) WITH TIME ZONE not null
);

create SEQUENCE idFlightSequence START WITH 1
INCREMENT BY 1
NOMAXVALUE;

create table WEATHER
(
  ID                    NUMBER       not null
    constraint WEATHER_ID
    primary key,
  PRESSURE              VARCHAR2(20) not null,
  DEW_POINT_TEMPERATURE NUMBER       not null,
  SURFACE_TEMPERATURE   NUMBER       not null,
  CLOUD_COVER           VARCHAR2(20) not null,
  VISIBILITY            VARCHAR2(20) not null,
  ISSUING_AIRPORT       VARCHAR2(20) not null,
  WIND_DIRECTION        VARCHAR2(20),
  WIND_SPEED            VARCHAR2(20),
  DATE_TIME             TIMESTAMP(6) WITH TIME ZONE
);

create SEQUENCE idWeatherSequence START WITH 1
INCREMENT BY 1
NOMAXVALUE;

drop table thermal;
drop sequence idThermalSequence;

create SEQUENCE idThermalSequence START WITH 1
INCREMENT BY 1
NOMAXVALUE;

CREATE table thermal(
  id int not null constraint thermal_id primary key,
  flight_id varchar2 (15) not null,
  date_found date not null,
  maxLatitude number not null,
	minLatitude number not null,
  maxLongitude number not null,
  minLongitude number not null
);
