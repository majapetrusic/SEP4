package logConverter;

import java.util.GregorianCalendar;

public class Weather
{
   private double pressure;
   private double dewPointTemperature;
   private double surfaceTemperature;
   private String cloudCover;
   private String visibility;
   private double windDirection;
   private double windSpeed;
   private int DD;
   private int HH;
   private int MM;
   private String airport;
   
   public Weather(String airport, int dD, int hH, int mM,double windDirection, double windSpeed, 
         String visibility, String cloudCover, double surfaceTemperature, double dewPointTemperature, double pressure) {
      this.airport = airport;
      DD = dD;
      HH = hH;
      MM = mM;
      this.windDirection = windDirection;
      this.windSpeed = windSpeed;
      this.visibility = visibility;
      this.cloudCover = cloudCover;
      this.surfaceTemperature = surfaceTemperature;
      this.dewPointTemperature = dewPointTemperature;
      this.pressure = pressure;  
   }

   public double getPressure() {
      return pressure;
   }

   public double getDewPointTemperature() {
      return dewPointTemperature;
   }

   public double getSurfaceTemperature() {
      return surfaceTemperature;
   }

   public String getCloudCover() {
      return cloudCover;
   }
   

   public String getVisibility() {
      return visibility;
   }
   
   public double getWindDirection(){
      return windDirection;
   }
   
   public double getWindSpeed(){
      return windSpeed;
   }
   
   public int getDD(){
      return DD;
   }

   public int getHH() {
      return HH;
   }

   public int getMM() {
      return MM;
   }
   
   public String getAirport(){
      return airport;
   }

}
