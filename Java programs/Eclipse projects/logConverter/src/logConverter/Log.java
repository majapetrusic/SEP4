package logConverter;

import java.util.GregorianCalendar;

public class Log {
 
	private double gpsAltitude;
	private double pressureAltitude;
	private char sateliteCoverage;
	private String positionLongitude;
	private String positionLatitude;
	private int HH;
	private int MM;
	private int SS;
	
	public Log(double gpsAltitude, double pressureAltitude, char sateliteCoverage, 
			String positionLatitude, String positionLongitude, int hH, int mM, int sS) {
		this.gpsAltitude = gpsAltitude;
		this.pressureAltitude = pressureAltitude;
		this.sateliteCoverage = sateliteCoverage;
	    this.positionLongitude = positionLongitude;
		this.positionLatitude = positionLatitude;
		HH = hH;
		MM = mM;
		SS = sS;
	}

	public double getGpsAltitude() {
		return gpsAltitude;
	}

	public double getPressureAltitude() {
		return pressureAltitude;
	}

	public char getSateliteCoverage() {
		return sateliteCoverage;
	}

	public String getPositionLongitude() {
		return positionLongitude;
	}

	public String getPositionLatitude() {
		return positionLatitude;
	}

	public int getHH() {
		return HH;
	}

	public int getMM() {
		return MM;
	}

	public int getSS() {
		return SS;
	}

}