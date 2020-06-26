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

void MHZ19_measure(DynamicJsonDocument &doc)
{
  Serial.println("============= MHZ19 =============");

  double CO2RAW = myMHZ19.getCO2Raw(); // issue
  double adjustedCO2 = 6.60435861e+15 * exp(-8.78661228e-04 * CO2RAW); // Exponential equation for Raw & CO2 relationship
  int8_t Temp = myMHZ19.getTemperature(); // Request Temperature (as Celsius)

  // /* get sensor readings as signed integer */
  int16_t CO2Unlimited = myMHZ19.getCO2(true, true);
  int16_t CO2limited = myMHZ19.getCO2(false, true);
  int16_t CO2background = myMHZ19.getBackgroundCO2();
  if (myMHZ19.errorCode != RESULT_OK)
  {
    Serial.println("Error found in communication :(");
    return;
  }

  doc["MHZ19"]["Temperature"]["value"] = String(Temp);
  doc["MHZ19"]["Temperature"]["type"] = "°C";
  doc["MHZ19"]["Temperature"]["isCalibrated"] = true;

  doc["MHZ19"]["Adjusted CO2"]["value"] = String(adjustedCO2);
  doc["MHZ19"]["Adjusted CO2"]["type"] = "ppm";
  doc["MHZ19"]["Adjusted CO2"]["isCalibrated"] = true;

  doc["MHZ19"]["Unlimited CO2"]["value"] = String(CO2Unlimited);
  doc["MHZ19"]["Unlimited CO2"]["type"] = "ppm";
  doc["MHZ19"]["Unlimited CO2"]["isCalibrated"] = true;

  doc["MHZ19"]["limited CO2"]["value"] = String(CO2limited);
  doc["MHZ19"]["limited CO2"]["type"] = "ppm";
  doc["MHZ19"]["limited CO2"]["isCalibrated"] = true;

  doc["MHZ19"]["background CO2"]["value"] = String(CO2background);
  doc["MHZ19"]["background CO2"]["type"] = "ppm";
  doc["MHZ19"]["background CO2"]["isCalibrated"] = true;

  doc["MHZ19"]["Raw CO2"]["value"] = String(CO2RAW);
}
