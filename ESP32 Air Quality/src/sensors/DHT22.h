#include <ArduinoJson.h>
#include <DHT.h>
#include <DHT_U.h>

#define DHTPIN 4      // Digital pin connected to the DHT sensor
#define DHTTYPE DHT22 // DHT 22 (AM2302)

DHT_Unified dht(DHTPIN, DHTTYPE);
class MyDHT22 {
private:
  sensors_event_t event;
  bool debug = false;
  bool internalError = false;

public:
  MyDHT22() {
    dht.begin();
    Serial.println(F("DHT22"));

    if (debug) {
      sensor_t sensor;
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
  }

  bool doMeasure() {
    Serial.println("============= DHT22 =============");
    internalError = false;
    // Get temperature event
    dht.temperature().getEvent(&event);
    if (isnan(event.temperature)) {
      Serial.println(F("Error reading temperature :("));
      internalError = true;
      return false;
    }

    // Get humidity event
    dht.humidity().getEvent(&event);
    if (isnan(event.relative_humidity)) {
      Serial.println(F("Error reading humidity :("));
      internalError = true;
      return false;
    }

    return true;
  }

  void toJSON(JsonArray &Sensors) {
    if (internalError) return;
    
    {
      JsonObject Sensors_0 = Sensors.createNestedObject();
      Sensors_0["sensor"] = "DHT22";
      Sensors_0["name"] = "Temperature";
      Sensors_0["value"] = event.temperature;
      Sensors_0["metric"] = "°C";
      Sensors_0["isCalibrated"] = true;
    }
    {
      JsonObject Sensors_0 = Sensors.createNestedObject();
      Sensors_0["sensor"] = "DHT22";
      Sensors_0["name"] = "Humidity";
      Sensors_0["value"] = event.relative_humidity;
      Sensors_0["metric"] = "%";
      Sensors_0["isCalibrated"] = true;
    }
  }
};
