#define DEBUG true // print messages in serial port

#include <ArduinoJson.h>

#include <Wire.h>
#include <SPI.h>
#include <Adafruit_Sensor.h>
#include "Adafruit_BME680.h"

#define SEALEVELPRESSURE_HPA (1013.25)

Adafruit_BME680 bme; // I2C

void BME680_init()
{
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
}

void BME680_measure(DynamicJsonDocument &doc)
{
  Serial.println("============= BME680 =============");

  // Tell BME680 to begin measurement.
  unsigned long endTime = bme.beginReading();
  if (endTime == 0)
  {
    Serial.println(F("Failed to begin reading bme :("));
    return;
  }

  delay(50);

  if (!bme.endReading())
  {
    Serial.println(F("Failed to complete reading :("));
    return;
  }

  doc["BME680"]["Temperature"]["value"] = bme.temperature;
  doc["BME680"]["Temperature"]["type"] = "°C";
  doc["BME680"]["Temperature"]["isCalibrated"] = true;

  doc["BME680"]["Pressure"]["value"] = bme.pressure / 100.0;
  doc["BME680"]["Pressure"]["type"] = "hPa";
  doc["BME680"]["Pressure"]["isCalibrated"] = true;

  doc["BME680"]["Humidity"]["value"] = bme.humidity;
  doc["BME680"]["Humidity"]["type"] = "%";
  doc["BME680"]["Humidity"]["isCalibrated"] = true;

  doc["BME680"]["Gas"]["value"] = bme.gas_resistance / 1000.0;
  doc["BME680"]["Gas"]["type"] = "KOhms";
  doc["BME680"]["Gas"]["isCalibrated"] = true;

  doc["BME680"]["Approx. Altitude"]["value"] = bme.readAltitude(SEALEVELPRESSURE_HPA);
  doc["BME680"]["Approx. Altitude"]["type"] = "m";
  doc["BME680"]["Approx. Altitude"]["isCalibrated"] = true;

}
