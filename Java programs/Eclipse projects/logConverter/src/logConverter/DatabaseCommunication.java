package logConverter;

import java.sql.Statement;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.SQLIntegrityConstraintViolationException;
import java.sql.Time;
import java.sql.Timestamp;
import java.util.Calendar;
import java.util.GregorianCalendar;
import java.util.TimeZone;


public class DatabaseCommunication {

	private static DatabaseCommunication instance;
	private final static String connectString = "jdbc:oracle:thin:@localhost:1521:xe"; //orabbc12c
	private final static String userName = "sep";
	private final static String password = "sep";
	private static Connection conn;
	
	private DatabaseCommunication() {
		try {
			DriverManager.registerDriver(new oracle.jdbc.OracleDriver());
			conn = DriverManager.getConnection(connectString, userName, password);
			conn.setAutoCommit(false);
			
		} catch (SQLException e) {
			e.printStackTrace();
		}
	}
	
	public static DatabaseCommunication getInstance() {
		
		if (instance == null) {
			instance = new DatabaseCommunication();
		}
		return instance;
	}
	
	public void insertLog(Log log, String fileName, int day, int month, int year) throws SQLException {
		Statement statement = conn.createStatement();
		statement.executeQuery("insert into flight "
				+ "(ID, gps_altitude, pressure_altitude, satellite_coverage, position_longitude, position_latitude, log_time, flight_id)"
				+ " values (idFlightSequence.nextval"
				+ "," + log.getGpsAltitude()
				+ "," + log.getPressureAltitude()
				+ ",'" + log.getSateliteCoverage() + "'"
				+ ",'" + log.getPositionLatitude() + "'"
				+ ",'" + log.getPositionLongitude() + "'"
				+ ", timestamp '" + (year + 2000) + "-" + month + "-" + day + " " + log.getHH() + ":" + log.getMM() + ":" + log.getSS() + "UTC'"
				+ ",'" + fileName + "'"
				+ ")");
		statement.close();
		conn.commit();
		}
	
	public void insertWeather(Weather weather, String fileName, int month, int year) throws SQLException {
	   Statement statement = conn.createStatement();
      statement.executeQuery("insert into weather "
            + "(ID, PRESSURE, DEW_POINT_TEMPERATURE, SURFACE_TEMPERATURE, CLOUD_COVER, VISIBILITY, ISSUING_AIRPORT, WIND_DIRECTION, WIND_SPEED, DATE_TIME)"
            + " values (idWeatherSequence.nextval"
            + "," + weather.getPressure()
            + "," + weather.getDewPointTemperature()
            + "," + weather.getSurfaceTemperature() 
            + ",'" + weather.getCloudCover() + "'"
            + ",'" + weather.getVisibility() + "'"
            + ",'" + weather.getAirport() + "'" 
            + "," + weather.getWindDirection()
            + "," + weather.getWindSpeed()
            + ", timestamp '" + (year) + "-" + month + "-" + weather.getDD() + " " + weather.getHH() + ":" + weather.getMM() + ":" + 00 + " " + "UTC'"
            + ")");
      statement.close();
      conn.commit();
      }
   
	
}