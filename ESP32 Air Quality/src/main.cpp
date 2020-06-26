// https://arduinojson.org/v6/assistant/

#include <Arduino.h>

#include <WiFi.h>
#include "NTPClient.h"
#include <WiFiUdp.h>

#include <ArduinoJson.h>
#include <HTTPClient.h>
#include <ESP32Ping.h>

#include <Ticker.h> //Ticker Library

#include "sensors/DHT22.h"
#include "sensors/BME680.h"
#include "sensors/MHZ19.h"
#include "sensors/MICS6814.h"
#include "sensors/SGP30.h"

#include "mynetwork.h"

String jsonOutput;
DynamicJsonDocument doc(2048);

void blink_LED();
void sendDataToFirebase();
void sendDataToLocalNetwork();

Ticker timer0(blink_LED, 1000);                    // each second blink led
Ticker timer1(sendDataToFirebase, 10 * 60 * 1000); // each 10 min send data to server
Ticker timer2(sendDataToLocalNetwork, 15 * 1000);  // each 10 second send data in local network

char WIFI_SSID[] = "idoomAdsl01";             // this is fine
const char *WIFI_PASSWORD = "builder2019cpp"; // this is fine
void setupWiFi();

void setup()
{
  Serial.begin(115200);
  // Device to serial monitor feedback
  while (!Serial)
    ;

  setupWiFi();

  // pinMode(BUILTIN_LED, OUTPUT);
  pinMode(LED_BUILTIN, OUTPUT);

  BME680_init();
  DHT22_init();
  MHZ19_init();
  MICS6814_init();
  SGP30_init();

  timer0.start();
  timer1.start();
  timer2.start();

  // sendDataToLocalNetwork();
  sendDataToFirebase();
}

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

void loop()
{
  timer0.update();
  timer1.update();
  timer2.update();
}

void blink_LED()
{
  // digitalWrite(BUILTIN_LED, !(digitalRead(BUILTIN_LED))); //Invert Current State of LED
  digitalWrite(LED_BUILTIN, !(digitalRead(LED_BUILTIN))); //Invert Current State of LED
}

void sendDataToLocalNetwork()
{
  //clear RAM
  doc.clear();
  jsonOutput.clear();
  doc["GPS"]["latitude"]["value"] = 35.6935229;
  doc["GPS"]["longitude"]["value"] = -0.6140395;

  // getting data and convert it into JSON
  DHT22_measure(doc);
  delay(10);

  MICS6814_measure(doc);
  delay(10);

  SGP30_measure(doc);
  delay(10);

  BME680_measure(doc);
  delay(10);

  MHZ19_measure(doc);
  delay(10);

  //print data in serial port
  serializeJsonPretty(doc, Serial);
}

void sendDataToFirebase()
{

  //clear RAM
  doc.clear();
  jsonOutput.clear();
  doc["GPS"]["latitude"]["value"] = 35.6935229;
  doc["GPS"]["longitude"]["value"] = -0.6140395;
  // getting data and convert it into JSON
  DHT22_measure(doc);
  delay(10);

  MICS6814_measure(doc);
  delay(10);

  SGP30_measure(doc);
  delay(10);

  BME680_measure(doc);
  delay(10);

  MHZ19_measure(doc);
  delay(10);

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
      ESP.restart(); //TODO: send msg + err in local network before restarting ....
    }
  }
  else
  {
    Serial.println("Connection lost");
    ESP.restart(); //TODO: send msg + err in local network before restarting ....
  }
  delay(1000);
}
