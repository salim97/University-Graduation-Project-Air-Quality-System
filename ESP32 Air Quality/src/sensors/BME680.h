#ifndef MyBME680_H
#define MyBME680_H

#include "MySensor.h"
#include <Adafruit_BME680.h>
#include <Adafruit_Sensor.h>
#include <SPI.h>
#include <Wire.h>

#define SEALEVELPRESSURE_HPA (1013.25)

class MyBME680 : public MySensor {
private:
  Adafruit_BME680 bme; // I2C
  bool internalError = false;

public:
  virtual String sensorName() { return "BME680"; }
  virtual bool init() {
    Serial.println(F("BME680 async test"));
    if (!bme.begin()) {
      Serial.println("Failed to start BME680 gas sensor - check wiring.");
      return false;
    }
    // Set up oversampling and filter initialization
    bme.setTemperatureOversampling(BME680_OS_8X);
    bme.setHumidityOversampling(BME680_OS_2X);
    bme.setPressureOversampling(BME680_OS_4X);
    bme.setIIRFilterSize(BME680_FILTER_SIZE_3);
    bme.setGasHeater(320, 150); // 320*C for 150 ms

    return doMeasure();
  }
  virtual bool doMeasure() {
    if (_Sensors_DEBUG) Serial.println("============= BME680 =============");
    internalError = false;
    // Tell BME680 to begin measurement.
    unsigned long endTime = bme.beginReading();
    if (endTime == 0) {
      Serial.println(F("Failed to begin reading bme :("));
      internalError = true;
      return false;
    }

    delay(50);

    if (!bme.endReading()) {
      Serial.println(F("Failed to complete reading :("));
      internalError = true;
      return false;
    }

    return true;
  }
  virtual void toJSON(JsonArray &Sensors) {
    if (internalError) return;
    {
      JsonObject Sensors_0 = Sensors.createNestedObject();
      Sensors_0["sensor"] = "BME680";
      Sensors_0["name"] = "Temperature";
      Sensors_0["value"] = bme.temperature;
      Sensors_0["metric"] = "°C";
      Sensors_0["isCalibrated"] = true;
    }

    {
      JsonObject Sensors_0 = Sensors.createNestedObject();
      Sensors_0["sensor"] = "BME680";
      Sensors_0["name"] = "Pressure";
      Sensors_0["value"] = bme.pressure / 100.0;
      Sensors_0["metric"] = "hPa";
      Sensors_0["isCalibrated"] = true;
    }

    {
      JsonObject Sensors_0 = Sensors.createNestedObject();
      Sensors_0["sensor"] = "BME680";
      Sensors_0["name"] = "Humidity";
      Sensors_0["value"] = bme.humidity;
      Sensors_0["metric"] = "%";
      Sensors_0["isCalibrated"] = true;
    }

    {
      JsonObject Sensors_0 = Sensors.createNestedObject();
      Sensors_0["sensor"] = "BME680";
      Sensors_0["name"] = "Gas";
      Sensors_0["value"] = bme.gas_resistance / 1000.0;
      Sensors_0["metric"] = "KOhms";
      Sensors_0["isCalibrated"] = true;
    }
    // {
    //   JsonObject Sensors_0 = Sensors.createNestedObject();
    //   Sensors_0["sensor"] = "BME680";
    //   Sensors_0["name"] = "Approx. Altitude";
    //   Sensors_0["value"] = bme.readAltitude(SEALEVELPRESSURE_HPA);
    //   Sensors_0["metric"] = "m";
    //   Sensors_0["isCalibrated"] = true;
    // }
  }
};

#endif