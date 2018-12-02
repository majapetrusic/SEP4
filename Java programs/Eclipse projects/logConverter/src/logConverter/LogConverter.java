package logConverter;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.nio.file.FileSystems;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.sql.SQLException;
import java.util.GregorianCalendar;

public class LogConverter {

	private File[] files;
	private DatabaseCommunication db;
	private int day;
	private int month;
	private int year;
	
	public LogConverter() throws IOException {
		File forder = new File("logs");
		files = forder.listFiles();
		db = DatabaseCommunication.getInstance();
		for (int a = 0; a < files.length; a++) {
			System.out.println(files[a].getName());
			convert(files[a]);
		}
	}
	
	public void convert(File file) throws IOException {
		FileReader fileReader = new FileReader(file);
		BufferedReader bufferedReader = new BufferedReader(fileReader);
		String line;
		while((line = bufferedReader.readLine()) != null) {
			if(line.charAt(0) == 'B') {
				Log log = new Log(
						Double.parseDouble(line.substring(30, 35)),
						Double.parseDouble(line.substring(25, 30)),
						line.charAt(24),
						line.substring(15, 24),
						line.substring(7, 15),
						Integer.parseInt(line.substring(1, 3)),
						Integer.parseInt(line.substring(3, 5)),
						Integer.parseInt(line.substring(5, 7)));
				try {
					db.insertLog(log, file.getName().substring(0, file.getName().length() - 4), day, month, year);
				} catch (SQLException e) {
					System.out.println(line);
					e.printStackTrace();
				}
			}
			else if (line.substring(0, 5).equals("HFDTE")) {
				day = Integer.parseInt(line.substring(5, 7));
				month = Integer.parseInt(line.substring(7, 9));
				year = Integer.parseInt(line.substring(9, 11));
			}
		}
		bufferedReader.close();
        Path moveto = FileSystems.getDefault().getPath("logs_archive/" + file.getName());
        Path movefrom = FileSystems.getDefault().getPath(file.getPath());
        Files.move(movefrom, moveto, StandardCopyOption.ATOMIC_MOVE);
	}
	

	
	public static void main(String[] args) throws IOException {
		LogConverter converter = new LogConverter();
	}
}