#include <ArduinoJson.h>
#include <DHT.h>
#include <DHT_U.h>
#include <Wire.h>

#define DHTPIN 3      // Digital pin connected to the DHT sensor
// #define DHTTYPE DHT11 // DHT 11 
DHT_Unified dht11(DHTPIN, DHT11);
void DHT11_init()
{
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
// DynamicJsonDocument doc(2048);
void DHT11_measure(DynamicJsonDocument &doc)
{
    Serial.println("============= DHT11 =============");

    sensors_event_t event;
    // Get temperature event
    dht11.temperature().getEvent(&event);
    if (isnan(event.temperature))
    {
        Serial.println(F("Error reading temperature :("));
        return;
    }

    doc["DHT11"]["Temperature"]["value"] = event.temperature;
    doc["DHT11"]["Temperature"]["type"] = "°C";
    doc["DHT11"]["Temperature"]["isCalibrated"] = true;

    // Get humidity event
    dht11.humidity().getEvent(&event);
    if (isnan(event.relative_humidity))
    {
        Serial.println(F("Error reading humidity :("));
        return;
    }

    doc["DHT11"]["Humidity"]["value"] = event.relative_humidity;
    doc["DHT11"]["Humidity"]["type"] = "%";
    doc["DHT11"]["Humidity"]["isCalibrated"] = true;
}
