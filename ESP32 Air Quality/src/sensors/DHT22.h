#ifndef MyDHT22_H
#define MyDHT22_H

#include "MySensor.h"
#include <DHT.h>
#include <DHT_U.h>

#define DHTPIN 4      // Digital pin connected to the DHT sensor
#define DHTTYPE DHT22 // DHT 22 (AM2302)

DHT_Unified dht(DHTPIN, DHTTYPE);
class MyDHT22 : public MySensor {
private:
  sensors_event_t event1, event2;
  uint32_t delayMS;
  bool internalError = false;

public:
  virtual void init() {
    dht.begin();
    Serial.println(F("DHT22"));
    event2.relative_humidity = 0;
    event1.temperature = 0;
    sensor_t sensor;
    if (_Sensors_DEBUG) {

      // Print temperature sensor details.
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
    }
    dht.humidity().getSensor(&sensor);
    // Set delay between sensor readings based on sensor details.
    delayMS = sensor.min_delay / 1000;
  }

  virtual bool doMeasure() {
    if (_Sensors_DEBUG) Serial.println("============= DHT22 =============");

    int retry = 0;
    bool noError = false;
    while (retry < 5 && noError == false) {
      if (_doMeasure())
        noError = true;
      else
        retry++;
    }
    
    if (retry == 5 && noError == false)
      internalError = true;
    else
      internalError = false;

    return noError;
  }

  bool _doMeasure() {

    // Delay between measurements.
    delay(delayMS);
    sensors_event_t event;
    // Get temperature event
    dht.temperature().getEvent(&event);
    if (isnan(event.temperature)) {
      if (_Sensors_DEBUG) Serial.println(F("Error reading temperature :("));
      return false;
    }
    event1.temperature = event.temperature;

    // Get humidity event
    dht.humidity().getEvent(&event);
    if (isnan(event.relative_humidity)) {
      if (_Sensors_DEBUG) Serial.println(F("Error reading humidity :("));
      return false;
    }
    event2.relative_humidity = event.relative_humidity;

    return true;
  }

  virtual void toJSON(JsonArray &Sensors) {
    if (internalError) return;
    {
      JsonObject Sensors_0 = Sensors.createNestedObject();
      Sensors_0["sensor"] = "DHT22";
      Sensors_0["name"] = "Temperature";
      Sensors_0["value"] = event1.temperature;
      Sensors_0["metric"] = "°C";
      Sensors_0["isCalibrated"] = true;
    }
    {
      JsonObject Sensors_0 = Sensors.createNestedObject();
      Sensors_0["sensor"] = "DHT22";
      Sensors_0["name"] = "Humidity";
      Sensors_0["value"] = event2.relative_humidity;
      Sensors_0["metric"] = "%";
      Sensors_0["isCalibrated"] = true;
    }
  }
};

#endif 