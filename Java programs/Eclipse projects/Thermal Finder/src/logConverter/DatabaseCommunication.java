package logConverter;

import java.sql.Statement;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.SQLIntegrityConstraintViolationException;
import java.sql.Time;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.GregorianCalendar;
import java.util.TimeZone;

import Model.Flight;
import Model.Log;
import Model.Thermal;
import oracle.net.aso.r;


public class DatabaseCommunication {

	private static DatabaseCommunication instance;
	private final static String connectString = "jdbc:oracle:thin:@localhost:1521:xe";
	private final static String userName = "sep";
	private final static String password = "sep";
	private static Connection conn;
	
	private DatabaseCommunication() {
		try {
			DriverManager.registerDriver(new oracle.jdbc.OracleDriver());
			conn = DriverManager.getConnection(connectString, userName, password);
			
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
	
	
	public ArrayList<Flight> getFlights() throws SQLException {
		ArrayList<Flight> flights = new ArrayList<>();
		PreparedStatement statement = conn.prepareStatement("select distinct FLIGHT_ID from FLIGHT");
		ResultSet resultSet = statement.executeQuery();
		while (resultSet.next()) {
			flights.add(new Flight(resultSet.getString(1)));
			PreparedStatement stm = conn.prepareStatement("select POSITION_LATITUDE, POSITION_LONGITUDE, GPS_ALTITUDE, LOG_TIME from FLIGHT where FLIGHT_ID = ? order by LOG_TIME asc");
			stm.setString(1, resultSet.getString(1));
			ResultSet set = stm.executeQuery();
			while(set.next()) {
				flights.get(flights.size() - 1).getLogs().add(new Log(set.getString(1), set.getString(2), set.getInt(3), set.getDate(4)));
			}
			stm.close();
		}
		statement.close();
		return flights;
	}
	
	public void insertThermal(Thermal thermal, String flightId) throws SQLException {
		PreparedStatement statement = conn.prepareStatement("insert into thermal (id, date_found, maxLatitude, maxLongitude, minLatitude, minLongitude, flight_id) "
				+ "values (idThermalSequence.nextval,?,?,?,?,?,?)");
		statement.setDate(1, thermal.getDate());
		statement.setDouble(2, thermal.getMaxLatitude());
		statement.setDouble(3, thermal.getMaxLongitude());
		statement.setDouble(4, thermal.getMinLatitude());
		statement.setDouble(5, thermal.getMinLongitude());
		statement.setString(6, flightId);
		statement.executeQuery();
		statement.close();
	}
}