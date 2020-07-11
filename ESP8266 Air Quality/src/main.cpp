// https://arduinojson.org/v6/assistant/

#include <Arduino.h>
#include <ESP8266HTTPClient.h>
#include <ESP8266WIFI.h>


// #include <WiFi.h>
#include <WiFiUdp.h>
#include <ArduinoJson.h>

#include <Ticker.h> //Ticker Library

#include "sensors/DHT11.h"
#include "mynetwork.h"

// needed for library
#include <ESPAsyncWebServer.h>
#include <ESPAsyncWiFiManager.h> //https://github.com/tzapu/WiFiManager


String jsonOutput;
DynamicJsonDocument doc(2048);
void jsonBody();
void jsonHeader();
bool httpPOST(String url, String body);

void blink_LED();
void sendDataToFirebase();
void sendDataToLocalNetwork();
void processUDP(String command);

// each second blink led
Ticker timer0(blink_LED, 1000);
// each 10 min send data to server
Ticker timer1(sendDataToFirebase, 10 * 60 * 1000);
// each 15 second send data in local network
Ticker timer2(sendDataToLocalNetwork, 15 * 1000);

bool configMode = false;
void configModeCallback(AsyncWiFiManager *myWiFiManager) {
  Serial.println("Entered config mode");
  Serial.println(WiFi.softAPIP());
  // if you used auto generated SSID, print it
  Serial.println(myWiFiManager->getConfigPortalSSID());
  configMode = true;
}
void saveConfigCallback() {
  Serial.println("-----------------------------------------------------");
  Serial.println("Should save config");
  configMode = false;
}

AsyncWebServer server(80);
DNSServer dns;

void setup() {
  Serial.begin(115200);
  // Device to serial monitor feedback
  while (!Serial)
    ;
  // WiFiManager
  // Local intialization. Once its business is done, there is no need to keep it
  // around
  AsyncWiFiManager wifiManager(&server, &dns);
  // reset settings - for testing
  // wifiManager.resetSettings();
  // WiFi.disconnect(true, true);

  // set callback that gets called when connecting to previous WiFi fails, and
  // enters Access Point mode
  wifiManager.setAPCallback(configModeCallback);
  wifiManager.setSaveConfigCallback(saveConfigCallback);

  // fetches ssid and pass and tries to connect
  // if it does not connect it starts an access point with the specified name
  // here  "AutoConnectAP"
  // and goes into a blocking loop awaiting configuration
  if (!wifiManager.autoConnect()) {
    Serial.println("failed to connect and hit timeout");
    // reset and try again, or maybe put it to deep sleep
    ESP.restart();
    delay(1000);
  }


  if (configMode) return;

  init_udp();
  // pinMode(BUILTIN_LED, OUTPUT);
  pinMode(LED_BUILTIN, OUTPUT);
  blink_LED();

  DHT11_init();

  timer0.start();
  timer1.start();
  timer2.start();
  // timer3.start();

  sendDataToLocalNetwork();
  sendDataToFirebase();
  // delay(60*60 * 1000);
}

void loop() {
  if (configMode) return;

  timer0.update();
  timer1.update();
  timer2.update();
  processUDP(readAllUDP());
}

void blink_LED() {
  digitalWrite(LED_BUILTIN,
               !(digitalRead(LED_BUILTIN))); // Invert Current State of LED
}

void sendDataToLocalNetwork() {

  jsonHeader();
  jsonBody();
  serializeJson(doc, jsonOutput);
  sendUDP(jsonOutput);
}

void sendDataToFirebase() {
  String url =
      "http://us-central1-pfe-air-quality.cloudfunctions.net/addRecord";

  jsonHeader();
  jsonBody();
  serializeJson(doc, jsonOutput);
  httpPOST(url, jsonOutput);
}

bool httpPOST(String url, String body) {
  if (WiFi.status() == WL_CONNECTED) {

    HTTPClient clientHTTP;

    // "https://postman-echo.com/post";

    if (clientHTTP.begin(url)) {
      clientHTTP.addHeader("Content-Type", "application/json");
      // clientHTTP.addHeader("Connection", "keep-alive");

      int httpCode = clientHTTP.POST(body);
      if (httpCode > 0) {
        String payload = clientHTTP.getString();
        Serial.println(payload);
        Serial.println("Status code : " + String(httpCode));
        clientHTTP.end();
        if (httpCode > 400) {
          delay(15 * 1000);
          ESP.restart();
        }
      } else {
        Serial.println("Error on HTTP request");
        Serial.println(clientHTTP.errorToString(httpCode));
        delay(5 * 1000);
        ESP.restart(); // TODO: send msg + err in local network before
        // restarting
        // ....
      }
    } else {
      Serial.printf("[HTTP] Unable to connect");
      Serial.printf(url.c_str());
      ESP.restart();
    }

  } else {
    Serial.println("WiFi.status() == WL_CONNECTED, no WiFi");
    ESP.restart(); // TODO: send msg + err in local network before restarting
                   // ....
  }
  delay(1000);
  return true;
}

void jsonHeader() {
  // clear RAM
  doc.clear();
  jsonOutput.clear();
  doc["uid"] = "L7tf0KusN9g2buXf21rQ46qmDRB3";
  doc["GPS"]["latitude"] = 35.62101;
  doc["GPS"]["longitude"] = -0.725109;
  doc["upTime"] = millis();
}

void jsonBody() {
  // getting data and convert it into JSON
  JsonArray Sensors = doc.createNestedArray("Sensors");
  if (!DHT11_measure(Sensors)) networkBroadcatLog("DHT11 ERROR!", true);
  delay(10);
}

void processUDP(String command) {
  DynamicJsonDocument _doc(2048);
  deserializeJson(_doc, command);
  if (_doc["command"] == "getData") {
    sendDataToLocalNetwork();
    return;
  }
  // if (_doc["command"] == "setWiFi") {
  //   clearEPPROM();
  //   setSSID(doc["ssid"]);
  //   setPASS(doc["pass"]);
  //   ESP.restart();
  // }
}