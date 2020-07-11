// https://arduinojson.org/v6/assistant/

// #include "NTPClient.h"
#include <Arduino.h>
// #include <WiFi.h>
#include <WiFiUdp.h>

#include <ArduinoJson.h>
#include <HTTPClient.h>

#include <Ticker.h> //Ticker Library

#include "sensors/BME680.h"
#include "sensors/DHT22.h"
#include "sensors/MHZ19.h"
#include "sensors/MICS6814.h"
#include "sensors/SGP30.h"

#include "mynetwork.h"

#include <WiFi.h>

// needed for library
#include <ESPAsyncWebServer.h>
#include <ESPAsyncWiFiManager.h> //https://github.com/tzapu/WiFiManager
#include <esp_wifi.h>

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

  // if you get here you have connected to the WiFi
  // WiFi.disconnect(true, true);
  wifi_config_t conf;
  esp_wifi_get_config(WIFI_IF_STA, &conf);
  Serial.println("SSID: " +
                 String(reinterpret_cast<const char *>(conf.sta.ssid)));
  Serial.println("PASS: " +
                 String(reinterpret_cast<const char *>(conf.sta.password)));
  if (configMode) return;

  init_udp();
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
      "https://us-central1-pfe-air-quality.cloudfunctions.net/addRecord";

  {
    jsonHeader();
    // you can optimized in the future
    JsonArray Sensors = doc.createNestedArray("Sensors");

    if (!SGP30_measure(Sensors)) networkBroadcatLog("SGP30 ERROR!", true);
    delay(10);
    serializeJson(doc, jsonOutput);
    httpPOST(url, jsonOutput);
  }

  {
    jsonHeader();
    // you can optimized in the future
    JsonArray Sensors = doc.createNestedArray("Sensors");
    if (!DHT22_measure(Sensors)) networkBroadcatLog("DHT22 ERROR!", true);
    delay(10);

    if (!MICS6814_measure(Sensors)) networkBroadcatLog("MICS6814 ERROR!", true);
    delay(10);

    if (!BME680_measure(Sensors)) networkBroadcatLog("BME680 ERROR!", true);
    delay(10);

    if (!MHZ19_measure(Sensors)) networkBroadcatLog("MHZ19 ERROR!", true);
    delay(10);

    serializeJson(doc, jsonOutput);
    httpPOST(url, jsonOutput);
  }
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
  doc["uid"] = "Lf7gh5IDYxZgOmUXKhtaHSk6j9y2";
  doc["GPS"]["latitude"] = 35.6935229;
  doc["GPS"]["longitude"] = -0.6140395;
  doc["upTime"] = millis();
}

void jsonBody() {
  // getting data and convert it into JSON
  JsonArray Sensors = doc.createNestedArray("Sensors");
  if (!DHT22_measure(Sensors)) networkBroadcatLog("DHT22 ERROR!", true);
  delay(10);

  if (!MICS6814_measure(Sensors)) networkBroadcatLog("MICS6814 ERROR!", true);
  delay(10);

  if (!SGP30_measure(Sensors)) networkBroadcatLog("SGP30 ERROR!", true);
  delay(10);

  if (!BME680_measure(Sensors)) networkBroadcatLog("BME680 ERROR!", true);
  delay(10);

  if (!MHZ19_measure(Sensors)) networkBroadcatLog("MHZ19 ERROR!", true);
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
