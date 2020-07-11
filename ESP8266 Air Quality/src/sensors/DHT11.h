#include <ArduinoJson.h>
#include <DHT.h>
#include <DHT_U.h>

#define DHTPIN D3 // Digital pin connected to the DHT sensor
// #define DHTTYPE DHT11 // DHT 11
DHT_Unified dht11(DHTPIN, DHT11);
void DHT11_init() {
  dht11.begin();
  Serial.println(F("DHT11"));
  sensor_t sensor;
  // Print temperature sensor details.
  dht11.temperature().getSensor(&sensor);
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
  dht11.humidity().getSensor(&sensor);
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

bool DHT11_measure(JsonArray &Sensors) {
  Serial.println("============= DHT11 =============");

  sensors_event_t event;
  // Get temperature event
  dht11.temperature().getEvent(&event);
  if (isnan(event.temperature)) {
    Serial.println(F("Error reading temperature :("));
    return false;
  }

  {
    JsonObject Sensors_0 = Sensors.createNestedObject();
    Sensors_0["sensor"] = "DHT11";
    Sensors_0["name"] = "Temperature";
    Sensors_0["value"] = event.temperature;
    Sensors_0["metric"] = "°C";
    Sensors_0["isCalibrated"] = true;
  }

  // Get humidity event
  dht11.humidity().getEvent(&event);
  if (isnan(event.relative_humidity)) {
    Serial.println(F("Error reading humidity :("));
    return false;
  }

  {
    JsonObject Sensors_0 = Sensors.createNestedObject();
    Sensors_0["sensor"] = "DHT11";
    Sensors_0["name"] = "Humidity";
    Sensors_0["value"] = event.relative_humidity;
    Sensors_0["metric"] = "%";
    Sensors_0["isCalibrated"] = true;
  }
  return true ;
}