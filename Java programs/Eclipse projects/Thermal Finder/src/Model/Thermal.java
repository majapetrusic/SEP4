package Model;

import java.sql.Date;
import java.util.ArrayList;

public class Thermal {

	public Thermal(Date date, ArrayList<Log> logs) {
		this.date = date;
		this.maxLatitude = logs.get(0).getLatitude();
		this.maxLongitude = logs.get(0).getLongitude();
		this.minLatitude = logs.get(0).getLatitude();
		this.minLongitude = logs.get(0).getLongitude();
		for (Log log : logs) {
			if (log.getLatitude() > maxLatitude) {
				maxLatitude = log.getLatitude();
			}
			if (log.getLatitude() < minLatitude) {
				minLatitude = log.getLatitude();
			}
			if (log.getLongitude() > maxLongitude) {
				maxLongitude = log.getLongitude();
			}
			if (log.getLongitude() < minLongitude) {
				minLongitude = log.getLongitude();
			}
		}
//		System.out.println(maxLatitude + " " + minLatitude + " " + maxLongitude + " " + minLongitude);
	}

	private Date date;
	private double maxLatitude;
	private double maxLongitude;
	private double minLatitude;
	private double minLongitude;

	public Date getDate() {
		return date;
	}

	public double getMaxLatitude() {
		return maxLatitude;
	}

	public double getMaxLongitude() {
		return maxLongitude;
	}

	public double getMinLatitude() {
		return minLatitude;
	}

	public double getMinLongitude() {
		return minLongitude;
	}
}