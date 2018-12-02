package Model;

import java.util.ArrayList;

public class Flight {

	private String name;
	private ArrayList<Log> logs;

	public String getName() {
		return name;
	}

	public ArrayList<Log> getLogs() {
		return logs;
	}

	public Flight(String name) {
		this.name = name;
		this.logs = new ArrayList<>();
	}
}
