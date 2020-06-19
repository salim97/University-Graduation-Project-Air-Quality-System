// https://arduinojson.org/v6/assistant/

#include <Arduino.h>
#include "mynetwork.h"
String proccessData(String data);
#include "MHZ19.h"
#include <SoftwareSerial.h> // Remove if using HardwareSerial or Arduino package without SoftwareSerial support

#include <Wire.h>
#include <SPI.h>
#include <Adafruit_Sensor.h>
#include "Adafruit_BME680.h"

#include "Adafruit_SGP30.h"

#include <Arduino.h>
#include <driver/adc.h>

#include <Adafruit_Sensor.h>
#include <DHT.h>
#include <DHT_U.h>
#include <MICS6814.h>

#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>

#include <WiFi.h>
// #include <FirebaseESP32.h>
#include "NTPClient.h"
#include <WiFiUdp.h>

#include <ArduinoJson.h>
#include <HTTPClient.h>
#include <ESP32Ping.h>

#define PIN_CO 32  // ADC1_CHANNEL_4
#define PIN_NO2 34 // ADC1_CHANNEL_6
#define PIN_NH3 35 // ADC1_CHANNEL_7

MICS6814 mics6814(PIN_CO, PIN_NO2, PIN_NH3);

#define DHTPIN 4      // Digital pin connected to the DHT sensor
#define DHTTYPE DHT22 // DHT 22 (AM2302)
DHT_Unified dht(DHTPIN, DHTTYPE);

void display_MICS6814();
void display_SGP30();
void display_BME680();
void display_MHZ19();
void display_DHT22();

Adafruit_SGP30 sgp;
//  return absolute humidity [mg/m^3] with approximation formula
//  @param temperature [°C]
//  @param humidity [%RH]

uint32_t getAbsoluteHumidity(float temperature, float humidity)
{
  // approximation formula from Sensirion SGP30 Driver Integration chapter 3.15
  const float absoluteHumidity = 216.7f * ((humidity / 100.0f) * 6.112f * exp((17.62f * temperature) / (243.12f + temperature)) / (273.15f + temperature)); // [g/m^3]
  const uint32_t absoluteHumidityScaled = static_cast<uint32_t>(1000.0f * absoluteHumidity);                                                                // [mg/m^3]
  return absoluteHumidityScaled;
}

#define SEALEVELPRESSURE_HPA (1013.25)

Adafruit_BME680 bme; // I2C

#define RX_PIN 23     // Rx pin which the MHZ19 Tx pin is attached to
#define TX_PIN 22     // Tx pin which the MHZ19 Rx pin is attached to
#define BAUDRATE 9600 // Device to MH-Z19 Serial baudrate (should not be changed)

MHZ19 myMHZ19; // Constructor for library

HardwareSerial mySerial(2); // (ESP32 Example) create device to MH-Z19 serial

unsigned long getDataTimer = 0;

// char WIFI_SSID[] = "room 02";                          // this is fine
char WIFI_SSID[] = "idoomAdsl01"; // this is fine
// char WIFI_SSID[] = "R6"; // this is fine
// const char *WIFI_PASSWORD = "qt2019cpp";               // this is fine
const char *WIFI_PASSWORD = "builder2019cpp"; // this is fine
// const char *WIFI_PASSWORD = "qt2019cpp";          // this is fine

// #define FIREBASE_HOST "pfe-air-quality.firebaseio.com" //Do not include https:// in FIREBASE_HOST
// #define FIREBASE_AUTH "U84MTjtIvoGz7ETqdPcZiibYRoRExLjuk5vdTDtv"
// FirebaseData firebaseData;
// FirebaseJson json;
// Define NTP Client to get time
// WiFiUDP ntpUDP;
// NTPClient timeClient(ntpUDP);
void sendToFirebase();
void setupWiFi()
{
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to Wi-Fi");
  while (WiFi.status() != WL_CONNECTED)
  {
    Serial.print(".");
    delay(300);
  }
  Serial.println();
  Serial.println(WIFI_PASSWORD);
  Serial.print("Connected with IP: ");
  Serial.println(WiFi.localIP());
  Serial.println();
}

// char jsonOutput[2048];
String jsonOutput;
//  StaticJsonDocument<512> doc;
// const size_t capacity = JSON_OBJECT_SIZE(1) + JSON_OBJECT_SIZE(2) + 2 * JSON_OBJECT_SIZE(3);
// DynamicJsonDocument doc(capacity);
DynamicJsonDocument doc(2048);
void setup()
{
  Serial.begin(115200);
  // Device to serial monitor feedback
  while (!Serial)
    ;

  Serial.println(F("MICS6814 calibrate"));
  mics6814.calibrate();
  // if (!mics6814_init())
  // {
  //   Serial.println("Failed to start MICS6814 gas sensor - check wiring.");
  //   while (1)
  //     ;
  // }

  Serial.println(F("BME680 async test"));

  if (!bme.begin())
  {
    Serial.println("Failed to start BME680 gas sensor - check wiring.");
    while (1)
      ;
  }

  // Set up oversampling and filter initialization
  bme.setTemperatureOversampling(BME680_OS_8X);
  bme.setHumidityOversampling(BME680_OS_2X);
  bme.setPressureOversampling(BME680_OS_4X);
  bme.setIIRFilterSize(BME680_FILTER_SIZE_3);
  bme.setGasHeater(320, 150); // 320*C for 150 ms

  if (!sgp.begin())
  {
    Serial.println("Failed to start SGP30 gas sensor - check wiring.");
    while (1)
      ;
  }
  Serial.print("Found SGP30 serial #");
  Serial.print(sgp.serialnumber[0], HEX);
  Serial.print(sgp.serialnumber[1], HEX);
  Serial.println(sgp.serialnumber[2], HEX);

  // If you have a baseline measurement from before you can assign it to start, to 'self-calibrate'
  //sgp.setIAQBaseline(0x8E68, 0x8F41);  // Will vary for each sensor!

  mySerial.begin(BAUDRATE);  // (Uno example) device to MH-Z19 serial start
  myMHZ19.begin(mySerial);   // *Serial(Stream) refence must be passed to library begin().
  myMHZ19.autoCalibration(); // Turn auto calibration ON (OFF autoCalibration(false))
  // myMHZ19.autoCalibration(false); // Turn auto calibration ON (OFF autoCalibration(false))

  dht.begin();
  // if (!dht.begin())
  // {
  //  Serial.println("Failed to start DHT22 gas sensor - check wiring.");
  // while (1)  ;
  // }
  // Print temperature sensor details.
  sensor_t sensor;
  dht.temperature().getSensor(&sensor);
  Serial.println(F("------------------------------------"));
  Serial.println(F("Temperature Sensor"));
  Serial.print(F("Sensor Type: "));
  Serial.println(sensor.name);
  Serial.print(F("Driver Ver:  "));
  Serial.println(sensor.version);
  Serial.print(F("Unique ID:   "));
  Serial.println(sensor.sensor_id);
  Serial.print(F("Max Value:   "));
  Serial.print(sensor.max_value);
  Serial.println(F("°C"));
  Serial.print(F("Min Value:   "));
  Serial.print(sensor.min_value);
  Serial.println(F("°C"));
  Serial.print(F("Resolution:  "));
  Serial.print(sensor.resolution);
  Serial.println(F("°C"));
  Serial.println(F("------------------------------------"));
  // Print humidity sensor details.
  dht.humidity().getSensor(&sensor);
  Serial.println(F("Humidity Sensor"));
  Serial.print(F("Sensor Type: "));
  Serial.println(sensor.name);
  Serial.print(F("Driver Ver:  "));
  Serial.println(sensor.version);
  Serial.print(F("Unique ID:   "));
  Serial.println(sensor.sensor_id);
  Serial.print(F("Max Value:   "));
  Serial.print(sensor.max_value);
  Serial.println(F("%"));
  Serial.print(F("Min Value:   "));
  Serial.print(sensor.min_value);
  Serial.println(F("%"));
  Serial.print(F("Resolution:  "));
  Serial.print(sensor.resolution);
  Serial.println(F("%"));
  Serial.println(F("------------------------------------"));

  setupWiFi();
}

void loop()
{
  //clear RAM
  doc.clear();
  jsonOutput.clear();
  doc["GPS"]["latitude"]["value"] = 35.6935229;
  doc["GPS"]["longitude"]["value"] = -0.6140395;
  // getting data and convert it into JSON
  display_DHT22();
  delay(100);

  display_MICS6814();
  delay(100);

  display_SGP30();
  delay(100);

  display_BME680();
  delay(100);

  display_MHZ19();
  delay(100);

  //print data in serial port
  serializeJsonPretty(doc, Serial);

  // bool success = Ping.ping("8.8.8.8", 3);

  // if (!success)
  // {
  //   Serial.println("Ping failed");
  //   // return;
  // }

  // Serial.println("Ping succesful.");

  // send data
  sendToFirebase();

  delay(10 * 60 * 1000);
}

void sendToFirebase()
{

  if (WiFi.status() == WL_CONNECTED)
  {
    HTTPClient clientHTTP;
    // clientHTTP.begin("http://192.168.1.103:5001/food-delivery-2020/us-central1/webApi/api/v1/postData");
    clientHTTP.begin("https://us-central1-pfe-air-quality.cloudfunctions.net/webApi/api/v1/postData");
    clientHTTP.addHeader("Content-Type", "application/json");

    // const size_t CAPACITY = JSON_OBJECT_SIZE(1);
    // StaticJsonDocument<200> doc;

    serializeJson(doc, jsonOutput);
    int httpCode = clientHTTP.POST(String(jsonOutput));

    if (httpCode > 0)
    {
      String payload = clientHTTP.getString();
      Serial.println("Status code : " + String(httpCode));
      Serial.println(payload);
      clientHTTP.end();
    }
    else
    {
      Serial.println("Error on HTTP request");
      ESP.restart();
    }
  }
  else
  {
    Serial.println("Connection lost");
    ESP.restart();
  }
  delay(1000);
}

void display_MHZ19()
{

  Serial.println("");
  Serial.println("============= MHZ19 =============");

  double CO2RAW = myMHZ19.getCO2Raw(); // issue
  // Serial.print("Raw CO2 : ");
  // Serial.println(CO2RAW, 0);

  double adjustedCO2 = 6.60435861e+15 * exp(-8.78661228e-04 * CO2RAW); // Exponential equation for Raw & CO2 relationship
  // Serial.print("Adjusted CO2 (ppm) : ");
  // Serial.println(adjustedCO2, 2);

  int8_t Temp = myMHZ19.getTemperature(); // Request Temperature (as Celsius)
                                          // Serial.print("Temperature (C): ");
                                          // Serial.println(Temp);

  // /* get sensor readings as signed integer */
  int16_t CO2Unlimited = myMHZ19.getCO2(true, true);
  int16_t CO2limited = myMHZ19.getCO2(false, true);
  int16_t CO2background = myMHZ19.getBackgroundCO2();
  if (myMHZ19.errorCode != RESULT_OK)
  {
    Serial.println("Error found in communication ");
    return;
  }
  // Serial.print("CO2 PPM Unlim: ");
  // Serial.println(CO2Unlimited);

  // Serial.print("CO2 PPM Lim: ");
  // Serial.println(CO2limited);

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

void display_BME680()
{
  Serial.println("");
  Serial.println("============= BME680 =============");
  // const size_t capacity = JSON_OBJECT_SIZE(1) + JSON_OBJECT_SIZE(2) + 2 * JSON_OBJECT_SIZE(3);
  // DynamicJsonDocument doc(capacity);
  // Tell BME680 to begin measurement.
  unsigned long endTime = bme.beginReading();
  if (endTime == 0)
  {
    Serial.println(F("Failed to begin reading bme :("));
    return;
  }

  // Serial.println(F("You can do other work during BME680 measurement."));
  delay(50); // This represents parallel work.

  if (!bme.endReading())
  {
    Serial.println(F("Failed to complete reading :("));
    return;
  }

  // Serial.print(F("Temperature  (°C) : "));
  // Serial.println(bme.temperature);
  doc["BME680"]["Temperature"]["value"] = bme.temperature;
  doc["BME680"]["Temperature"]["type"] = "°C";
  doc["BME680"]["Temperature"]["isCalibrated"] = true;

  // Serial.print(F("Pressure (hPa) : "));
  // Serial.println(bme.pressure / 100.0);
  doc["BME680"]["Pressure"]["value"] = bme.pressure / 100.0;
  doc["BME680"]["Pressure"]["type"] = "hPa";
  doc["BME680"]["Pressure"]["isCalibrated"] = true;

  // Serial.print(F("Humidity (%) : "));
  // Serial.println(bme.humidity);
  doc["BME680"]["Humidity"]["value"] = bme.humidity;
  doc["BME680"]["Humidity"]["type"] = "%";
  doc["BME680"]["Humidity"]["isCalibrated"] = true;

  // Serial.print(F("Gas (KOhms) : "));
  // Serial.println(bme.gas_resistance / 1000.0);
  doc["BME680"]["Gas"]["value"] = bme.gas_resistance / 1000.0;
  doc["BME680"]["Gas"]["type"] = "KOhms";
  doc["BME680"]["Gas"]["isCalibrated"] = true;

  // Serial.print(F("Approx. Altitude (m) : "));
  // Serial.println(bme.readAltitude(SEALEVELPRESSURE_HPA));
  doc["BME680"]["Approx. Altitude"]["value"] = bme.readAltitude(SEALEVELPRESSURE_HPA);
  doc["BME680"]["Approx. Altitude"]["type"] = "m";
  doc["BME680"]["Approx. Altitude"]["isCalibrated"] = true;

  // JsonObject MHZ19 = doc.createNestedObject("MHZ19");
  // JsonObject MHZ19_Temperature = MHZ19.createNestedObject("Temperature");
  // // MHZ19_Temperature["value"] =  String(Temp);
  // MHZ19_Temperature["type"] = "°C";
  // MHZ19_Temperature["isCalibrated"] = true;
  // JsonObject MHZ19_Adjusted_CO2 = MHZ19.createNestedObject("Adjusted CO2");
  // // MHZ19_Adjusted_CO2["value"] = String(adjustedCO2);
  // MHZ19_Adjusted_CO2["type"] = "PPM";
  // MHZ19_Adjusted_CO2["isCalibrated"] = true;

  // serializeJsonPretty(doc, Serial);

  // doc["BME680_Temperature"] = String(bme.temperature);
  // doc["BME680_Pressure_CO2"] = String(bme.pressure / 100.0);
  // doc["BME680_Humidity"] = String(bme.humidity);
  // doc["BME680_Gas (KOhms)"] = String(bme.gas_resistance / 1000.0);
  // doc["BME680_Approx. Altitude (m)"] = String(bme.readAltitude(SEALEVELPRESSURE_HPA));
}

void display_SGP30()
{
  Serial.println("");
  Serial.println("============= SGP30 =============");

  if (!sgp.IAQmeasure())
  {
    Serial.println("Measurement failed");
    return;
  }
  // Serial.print("TVOC (ppb) : ");
  // Serial.println(sgp.TVOC);
  doc["SGP30"]["TVOC"]["value"] = sgp.TVOC;
  doc["SGP30"]["TVOC"]["type"] = "PPB";
  doc["SGP30"]["TVOC"]["isCalibrated"] = true;

  // Serial.print("eCO2 (ppm) : ");
  // Serial.println(sgp.eCO2);
  doc["SGP30"]["eCO2"]["value"] = sgp.eCO2;
  doc["SGP30"]["eCO2"]["type"] = "PPM";
  doc["SGP30"]["eCO2"]["isCalibrated"] = true;
  // HERE <=================================

  if (!sgp.IAQmeasureRaw())
  {
    Serial.println("Raw Measurement failed");
    return;
  }
  // Serial.print("Raw H2 : ");
  // Serial.println(sgp.rawH2);
  doc["SGP30"]["Raw H2"]["value"] = sgp.rawH2;

  // Serial.print("Raw Ethanol : ");
  // Serial.println(sgp.rawEthanol);
  doc["SGP30"]["Raw Ethanol"]["value"] = sgp.rawEthanol;
}

void display_MICS6814()
{
  Serial.println("");
  Serial.println("============= MICS6814 =============");

  // Serial.print("NH3: ");
  // Serial.print(mics6814.getResistance(CH_NH3));
  // Serial.print("/");
  // Serial.print(mics6814.getBaseResistance(CH_NH3));
  // Serial.print(" = ");
  // Serial.print(mics6814.getCurrentRatio(CH_NH3));
  // Serial.print(" => ");
  // Serial.print(mics6814.measure(NH3));
  // Serial.println("ppm");
  // delay(50);

  // Serial.print("CO: ");
  // Serial.print(mics6814.getResistance(CH_CO));
  // Serial.print("/");
  // Serial.print(mics6814.getBaseResistance(CH_CO));
  // Serial.print(" = ");
  // Serial.print(mics6814.getCurrentRatio(CH_CO));
  // Serial.print(" => ");
  // Serial.print(mics6814.measure(CO));
  // Serial.println("ppm");
  // delay(50);

  // Serial.print("NO2: ");
  // Serial.print(mics6814.getResistance(CH_NO2));
  // Serial.print("/");
  // Serial.print(mics6814.getBaseResistance(CH_NO2));
  // Serial.print(" = ");
  // Serial.print(mics6814.getCurrentRatio(CH_NO2));
  // Serial.print(" => ");
  // Serial.print(mics6814.measure(NO2));
  // Serial.println("ppm");
  // delay(50);

  // Serial.print("NO2 (PPM) : ");
  // Serial.println(mics6814.measure(NO2));
  doc["MICS6814"]["NO2"]["value"] = mics6814.measure(NO2);
  doc["MICS6814"]["NO2"]["type"] = "PPM";
  doc["MICS6814"]["NO2"]["isCalibrated"] = true;

  // Serial.print("NH3 (PPM) : ");
  // Serial.println(mics6814.measure(NH3));
  doc["MICS6814"]["NH3"]["value"] = mics6814.measure(NH3);
  doc["MICS6814"]["NH3"]["type"] = "PPM";
  doc["MICS6814"]["NH3"]["isCalibrated"] = true;

  // Serial.print("CO (PPM) : ");
  // Serial.println(mics6814.measure(CO));
  doc["MICS6814"]["CO"]["value"] = mics6814.measure(CO);
  doc["MICS6814"]["CO"]["type"] = "PPM";
  doc["MICS6814"]["CO"]["isCalibrated"] = true;
}

void display_DHT22()
{
  Serial.println("");
  Serial.println("============= DHT22 =============");

  sensors_event_t event;
  dht.temperature().getEvent(&event);
  if (isnan(event.temperature))
  {
    Serial.println(F("Error reading temperature!"));
  }
  else
  {
    // Serial.print(F("Temperature (°C) : "));
    // Serial.println(event.temperature);
    doc["DHT22"]["Temperature"]["value"] = event.temperature;
    doc["DHT22"]["Temperature"]["type"] = "°C";
    doc["DHT22"]["Temperature"]["isCalibrated"] = true;
  }
  // Get humidity event and print its value.
  dht.humidity().getEvent(&event);
  if (isnan(event.relative_humidity))
  {
    Serial.println(F("Error reading humidity!"));
  }
  else
  {
    // Serial.print(F("Humidity (%) : "));
    // Serial.println(event.relative_humidity);
    doc["DHT22"]["Humidity"]["value"] = event.relative_humidity;
    doc["DHT22"]["Humidity"]["type"] = "%";
    doc["DHT22"]["Humidity"]["isCalibrated"] = true;
  }
}