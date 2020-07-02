// https://arduinojson.org/v6/assistant/

// #include "NTPClient.h"
#include <Arduino.h>
// #include <WiFi.h>
#include <WiFiUdp.h>

#include <ArduinoJson.h>
#include <ESP32Ping.h>
#include <HTTPClient.h>

#include <Ticker.h> //Ticker Library

#include "sensors/BME680.h"
#include "sensors/DHT22.h"
#include "sensors/MHZ19.h"
#include "sensors/MICS6814.h"
#include "sensors/SGP30.h"

#include "mynetwork.h"

String jsonOutput;
DynamicJsonDocument doc(2048);

void blink_LED();
void sendDataToFirebase();
void sendDataToLocalNetwork();
void processUDP(String command);
// void readDataFromSensors();

Ticker timer0(blink_LED, 1000); // each second blink led
Ticker timer1(sendDataToFirebase,
              10 * 60 * 1000); // each 10 min send data to server
Ticker timer2(sendDataToLocalNetwork,
              15 * 1000); // each 15 second send data in local network
// Ticker timer3(readDataFromSensors, 15 * 1000);  // each 10 second send data
// in local network
bool configMode = false;
void setup() {

  Serial.begin(115200);
  // Device to serial monitor feedback
  while (!Serial)
    ;

  if (!mynetwork_init()) {
    // config mode
    configMode = true;
    return;
  }

  // pinMode(BUILTIN_LED, OUTPUT);
  pinMode(LED_BUILTIN, OUTPUT);
  blink_LED();

  BME680_init();
  DHT22_init();
  MHZ19_init();
  MICS6814_init();
  SGP30_init();

  timer0.start();
  timer1.start();
  timer2.start();

  sendDataToLocalNetwork();
  sendDataToFirebase();
}

void loop() {
  if (configMode) return;
  timer0.update();
  timer1.update();
  timer2.update();
  // String command = readAllUDP();
  processUDP(readAllUDP());
}

void blink_LED() {
  // digitalWrite(BUILTIN_LED, !(digitalRead(BUILTIN_LED))); //Invert Current
  // State of LED
  digitalWrite(LED_BUILTIN,
               !(digitalRead(LED_BUILTIN))); // Invert Current State of LED
}

void sendDataToLocalNetwork() {
  // clear RAM
  doc.clear();
  jsonOutput.clear();
  doc["GPS"]["latitude"]["value"] = 35.6935229;
  doc["GPS"]["longitude"]["value"] = -0.6140395;
  doc["upTime"] = millis();

  // getting data and convert it into JSON
  if (!DHT22_measure(doc)) networkBroadcatLog("DHT22 ERROR!", true);
  delay(10);

  if (!MICS6814_measure(doc)) networkBroadcatLog("MICS6814 ERROR!", true);
  delay(10);

  if (!SGP30_measure(doc)) networkBroadcatLog("SGP30 ERROR!", true);
  delay(10);

  if (!BME680_measure(doc)) networkBroadcatLog("BME680 ERROR!", true);
  delay(10);

  if (!MHZ19_measure(doc)) networkBroadcatLog("MHZ19 ERROR!", true);
  delay(10);

  // print data in serial port
  serializeJsonPretty(doc, Serial);
  serializeJson(doc, jsonOutput);
  sendUDP(jsonOutput);
}

void sendDataToFirebase() {
  if (am_i_the_access_point())
    return; // if the esp is the access point, that mean there is no internet
            // connection ....
  // clear RAM
  doc.clear();
  jsonOutput.clear();
  doc["GPS"]["latitude"]["value"] = 35.6935229;
  doc["GPS"]["longitude"]["value"] = -0.6140395;
  doc["upTime"] = millis();
  // ESP.getch
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

  if (WiFi.status() == WL_CONNECTED) {
    HTTPClient clientHTTP;
    clientHTTP.begin("http://192.168.1.33:5001/pfe-air-quality/us-central1/"
                     "webApi/api/v1/postData");
    // clientHTTP.begin("https://us-central1-pfe-air-quality.cloudfunctions.net/webApi/api/v1/postData");

    clientHTTP.addHeader("Content-Type", "application/json");

    // const size_t CAPACITY = JSON_OBJECT_SIZE(1);
    // StaticJsonDocument<200> doc;

    serializeJson(doc, jsonOutput);
    int httpCode = clientHTTP.POST(String(jsonOutput));
    Serial.println("Status code : " + String(httpCode));
    if (httpCode > 0) {
      String payload = clientHTTP.getString();
      Serial.println("Status code : " + String(httpCode));
      Serial.println(payload);
      clientHTTP.end();
    } else {
      Serial.println("Error on HTTP request");
      ESP.restart(); // TODO: send msg + err in local network before restarting
                     // ....
    }
  } else {
    Serial.println("Connection lost");
    ESP.restart(); // TODO: send msg + err in local network before restarting
                   // ....
  }
  delay(1000);
}

void processUDP(String command) {
  DynamicJsonDocument _doc(1024);
  deserializeJson(_doc, command);
  if (doc["command"] == "getData") {
    sendDataToLocalNetwork();
    return;
  }
  if (doc["command"] == "setWiFi") {
    clearEPPROM();
    setSSID(doc["ssid"]);
    setPASS(doc["pass"]);
    ESP.restart();
  }
}