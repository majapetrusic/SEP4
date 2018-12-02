package logConverter;

import java.sql.SQLException;
import java.util.ArrayList;

import Model.Flight;
import Model.Log;
import Model.Thermal;

public class ThermalFinder {
	
	private ArrayList<Flight> flights;
	
	public ThermalFinder(ArrayList<Flight> flights) throws SQLException {
		this.flights = flights;
		for(int a = 0; a < flights.size(); a++) {
			ArrayList<Thermal> thermals = findThermal(flights.get(a));
			for (Thermal thermal : thermals) {
				DatabaseCommunication.getInstance().insertThermal(thermal, flights.get(a).getName());
			}
		}
	}

	public ArrayList<Thermal> findThermal(Flight flight) {
		ArrayList<Thermal> thermals = new ArrayList<>();
		
		ArrayList<Log> increment = new ArrayList<>();
		double lastAlt = flight.getLogs().get(0).getAltitude();
		for(int a = 1 ; a < flight.getLogs().size(); a++) {
			if(lastAlt <= flight.getLogs().get(a).getAltitude() && lastAlt > 500) {
				increment.add(flight.getLogs().get(a));
			}
			else {
				if (increment.size() > 10 && increment.get(increment.size() - 1).getAltitude() - increment.get(0).getAltitude() >= 100) {
					thermals.add(new Thermal(increment.get(0).getDate(), (ArrayList<Log>) increment.clone()));
				}
				increment = new ArrayList<>();
			}
			lastAlt = flight.getLogs().get(a).getAltitude();
		}
		System.out.println(thermals.size());
		return thermals;
	}
	
	public static void main(String []args) throws SQLException {
		ThermalFinder thermalFinder = new ThermalFinder(DatabaseCommunication.getInstance().getFlights());
	}
}
