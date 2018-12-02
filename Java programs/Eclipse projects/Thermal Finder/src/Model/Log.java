package Model;

import java.sql.Date;
import java.util.GregorianCalendar;

public class Log {

	private double latitude;
	private double longitude;
	private double altitude;
	private Date date;

	public Log(String latitude, String longitude, double altitude, Date date) {
		this.latitude = changeToDecimals(latitude);
		this.longitude = changeToDecimals(longitude);
		this.altitude = altitude;
		this.date = date;
	}
	
	private double changeToDecimals(String t) {
		double s = 1;
		if(t.charAt(t.length() - 1) == 'W' || t.charAt(t.length() - 1) == 'S') {
			s = -1;
		}
		double ss = Double.parseDouble(t.substring(t.length() - 4, t.length() - 1)) / 10.0;
		double mm = Double.parseDouble(t.substring(t.length() - 6, t.length() - 4));
		double d = Double.parseDouble(t.substring(0, t.length() - 6));
		double res = d + (mm / 60) + (ss / 3600);
		return res;
	}

	public double getLatitude() {
		return latitude;
	}

	public double getLongitude() {
		return longitude;
	}

	public double getAltitude() {
		return altitude;
	}
	
	public Date getDate() {
		return date;
	}
}
