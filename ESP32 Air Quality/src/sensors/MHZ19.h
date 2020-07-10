#include <ArduinoJson.h>
#include <MHZ19.h>
#include <SoftwareSerial.h> // Remove if using HardwareSerial or Arduino package without SoftwareSerial support

#define RX_PIN 23     // Rx pin which the MHZ19 Tx pin is attached to
#define TX_PIN 22     // Tx pin which the MHZ19 Rx pin is attached to
#define BAUDRATE 9600 // Device to MH-Z19 Serial baudrate (should not be changed)
HardwareSerial mySerial(2); // (ESP32 Example) create device to MH-Z19 serial


MHZ19 myMHZ19; // Constructor for library

void MHZ19_init()
{
  mySerial.begin(BAUDRATE);  // (Uno example) device to MH-Z19 serial start
  myMHZ19.begin(mySerial);   // *Serial(Stream) refence must be passed to library begin().
  myMHZ19.autoCalibration(); // Turn auto calibration ON (OFF autoCalibration(false))
  // myMHZ19.autoCalibration(false); // Turn auto calibration ON (OFF autoCalibration(false))
}

bool MHZ19_measure( JsonArray &Sensors)
{
  Serial.println("============= MHZ19 =============");

  double CO2RAW = myMHZ19.getCO2Raw(); // issue
  // double adjustedCO2 = 6.60435861e+15 * exp(-8.78661228e-04 * CO2RAW); // Exponential equation for Raw & CO2 relationship
  int8_t Temp = myMHZ19.getTemperature(); // Request Temperature (as Celsius)

  // /* get sensor readings as signed integer */
  int16_t CO2Unlimited = myMHZ19.getCO2(true, true);
  // int16_t CO2limited = myMHZ19.getCO2(false, true);
  // int16_t CO2background = myMHZ19.getBackgroundCO2();
  if (myMHZ19.errorCode != RESULT_OK)
  {
    Serial.println("Error found in communication :(");
    return false;
  }

  {
    JsonObject Sensors_0 = Sensors.createNestedObject();
    Sensors_0["sensor"] = "MHZ19";
    Sensors_0["name"] = "Temperature";
    Sensors_0["value"] =  Temp;
    Sensors_0["metric"] = "°C";
    Sensors_0["isCalibrated"] = true;
  }

  {
    JsonObject Sensors_0 = Sensors.createNestedObject();
    Sensors_0["sensor"] = "MHZ19";
    Sensors_0["name"] = "CO2";
    Sensors_0["value"] =  CO2Unlimited;
    Sensors_0["metric"] = "ppm";
    Sensors_0["isCalibrated"] = true;
  }



  {
    JsonObject Sensors_0 = Sensors.createNestedObject();
    Sensors_0["sensor"] = "MHZ19";
    Sensors_0["name"] = "Raw CO2";
    Sensors_0["value"] =  CO2RAW;
    Sensors_0["isCalibrated"] = true;
  }



  return true;
}
