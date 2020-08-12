// https://arduinojson.org/v6/assistant/

#include <Arduino.h>
#include <ESP8266HTTPClient.h>
#include <ESP8266WIFI.h>

// #include <WiFi.h>

#include <ArduinoJson.h>
#include <WiFiUdp.h>

#include <Ticker.h> //Ticker Library
#include <jled.h>
auto led_breathe = JLed(16).Breathe(2000).Forever();

#include "MyLocalNetworkEngine.h"
#include "MyServerConfig.h"
#include "My_REST_API.h"
// #include "sensors/MySensor.h"
#include "sensors/DHT11.h"

MySensor *mySensorsList[] = {new MyDHT11()};
#define sizeMySensorsList (sizeof(mySensorsList) / sizeof(mySensorsList[0]))

// needed for library
#include <ESPAsyncWebServer.h>
#include <ESPAsyncWiFiManager.h> //https://github.com/tzapu/WiFiManager
#include <EasyButton.h>

String globalSharedBuffer;
DynamicJsonDocument doc(4096);
String requestBodyReady();

void readAllSensors();
bool httpPOST(String url, String body);
void sendDataToFirebase();
void initWiFi();

// REST API
void setServerConfig(AsyncWebServerRequest *request);
void getServerConfig(AsyncWebServerRequest *request);
void getSensorsData(AsyncWebServerRequest *request);

// each 10 min send data to server
Ticker timer1(sendDataToFirebase, 10 * 60 * 1000);

bool configMode = false;
AsyncWebServer server(80);

MyServerConfig myServerConfig;
MyLocalNetworkEngine myLocalNetworkEngine;

// Instance of the button.
EasyButton resetFactoryButton(0);

void setup() {
  Serial.begin(115200);
  // Device to serial monitor feedback
  while (!Serial)
    ;
  // Initialize the button.
  resetFactoryButton.begin();
  // Add the callback function to be called when the button is pressed.
  resetFactoryButton.onPressed([]() {
    Serial.println("Reset Factory Button was pushed!\n");
    pinMode(16, OUTPUT);
    digitalWrite(16, LOW);

    for (int i = 0; i < 10; i++) {
      digitalWrite(16,
                   !(digitalRead(16))); // Invert Current State of LED
      delay(500);
    }
    WiFi.disconnect(true);
    myServerConfig.clearServerConfig();
    delay(100);
    ESP.restart();
  });

  initWiFi();

  myServerConfig.begin();
  myLocalNetworkEngine.begin();

  server.on("/status", HTTP_GET, getESP8266status);
  server.on("/sensors", HTTP_GET, getSensorsData);
  server.on("/serverConfig", HTTP_POST, setServerConfig);
  server.on("/serverConfig", HTTP_GET, getServerConfig);

  server.onNotFound([](AsyncWebServerRequest *request) {
    request->send(404, "text/plain", "Not found");
  });
  server.begin();

  if (configMode) return;

  // pinMode(BUILTIN_LED, OUTPUT);
  // pinMode(LED_BUILTIN, OUTPUT);

  for (uint8_t i = 0; i < sizeMySensorsList; i++) {
    if (!mySensorsList[i]->init()) {
      Serial.println("ALLLLEERRRTT ----------------------");
      // TODO : display led animation
    }
  }

  timer1.start();

  sendDataToFirebase();
}

void initWiFi() {

  // AsyncWebServer server(80);
  DNSServer dns;
  AsyncWiFiManager wifiManager(&server, &dns);
  // reset settings - for testing
  // wifiManager.resetSettings();
  // WiFi.disconnect(true, true);

  // set callback that gets called when connecting to previous WiFi fails, and
  // enters Access Point mode
  // wifiManager.setAPCallback(configModeCallback);
  wifiManager.setAPCallback([](AsyncWiFiManager *myWiFiManager) {
    Serial.println("Entered config mode");
    Serial.println(WiFi.softAPIP());
    // if you used auto generated SSID, print it
    Serial.println(myWiFiManager->getConfigPortalSSID());
    configMode = true;
  });
  wifiManager.setSaveConfigCallback([]() {
    Serial.println("-----------------------------------------------------");
    Serial.println("Should save config");
    configMode = false;
  });

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
  server.end();
}

void loop() {
  resetFactoryButton.read();
  if (configMode) return;
  led_breathe.Update();
  myLocalNetworkEngine.check();
  timer1.update();
  readAllSensors();
}

void sendDataToFirebase() {
  return;
  String url =
      "http://us-central1-pfe-air-quality.cloudfunctions.net/addRecord";

  serializeJson(doc, globalSharedBuffer);
  httpPOST(url, requestBodyReady());
}

bool httpPOST(String url, String body) {
  if (WiFi.status() == WL_CONNECTED) {

    HTTPClient clientHTTP;

    // "https://postman-echo.com/post";

#ifdef ESP32
    if (clientHTTP.begin(url))
#else
    WiFiClient client;
    if (clientHTTP.begin(client, url))
#endif
    {
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

String requestBodyReady() {
  String requestBodyReady;
  DeserializationError e;
  e = deserializeJson(doc, globalSharedBuffer);
  Serial.println(e.c_str());

  DynamicJsonDocument _doc(1024);
  e = deserializeJson(_doc, myServerConfig.getServerConfig());
  Serial.println(e.c_str());

  // Serial.println(e.c_str());
  doc["uid"] = _doc["uid"];
  doc["GPS"]["latitude"] = _doc["GPS_latitude"];
  doc["GPS"]["longitude"] = _doc["GPS_longitude"];
  doc["upTime"] = millis();
  serializeJsonPretty(doc, requestBodyReady);
  return requestBodyReady;
}

void readAllSensors() {
  bool oneSensorIsDown = false;
  for (uint8_t i = 0; i < sizeMySensorsList; i++) {
    // mySensorsList[i]->doMeasure();
    bool isOK = mySensorsList[i]->doMeasure();
    // if (!isOK) {
    //   Serial.println("ALLLLEERRRTT ----------------------");
    // }
    oneSensorIsDown = oneSensorIsDown || !isOK;
  }
  // setCoreSensorStatus(oneSensorIsDown);
  // TODO : play animation

  doc.clear();
  // getting data and convert it into JSON
  JsonArray Sensors = doc.createNestedArray("Sensors");
  for (uint8_t i = 0; i < sizeMySensorsList; i++) {
    mySensorsList[i]->toJSON(Sensors);
  }
  globalSharedBuffer.clear();
  serializeJson(doc, globalSharedBuffer);
  // // getting data and convert it into JSON
  // JsonArray Sensors = doc.createNestedArray("Sensors");
  // if (!DHT11_measure(Sensors)) networkBroadcatLog("DHT11 ERROR!", true);
  // delay(10);
}

//---------------------------------------------------------
// REST API
//---------------------------------------------------------

void setServerConfig(AsyncWebServerRequest *request) {
  String _jsonOutput;
  DynamicJsonDocument _doc(1024);

  String keys[4] = {"uid", "GPS_latitude", "GPS_longitude", "GPS_altitude"};
  for (int i = 0; i < 4; i++) {
    if (request->hasParam(keys[i], true)) {
      _doc[keys[i]] = request->getParam(keys[i], true)->value();
    } else {
      request->send(400, "text/plain", keys[i] + " not found.");
      return;
    }
  }

  serializeJsonPretty(_doc, _jsonOutput);
  myServerConfig.setServerConfig(_jsonOutput);
  request->send(200, "text/plain", _jsonOutput);
}

void getServerConfig(AsyncWebServerRequest *request) {
  String sc = myServerConfig.getServerConfig();
  if (sc.isEmpty())
    request->send(400, "text/plain", "Server Config is empty");
  else

    request->send(200, "text/plain", sc);
}

void getSensorsData(AsyncWebServerRequest *request) {
  request->send(200, "text/plain", globalSharedBuffer);
}
