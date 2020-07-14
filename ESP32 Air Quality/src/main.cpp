// https://arduinojson.org/v6/assistant/
// https://randomnerdtutorials.com/esp32-dual-core-arduino-ide/
// https://docs.espressif.com/projects/esp-idf/en/latest/esp32/api-guides/freertos-smp.html
// https://esp32.com/viewtopic.php?t=1703
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


String jsonOutputAllsensors;
String jsonOutputMTU1;
String jsonOutputMTU2;
DynamicJsonDocument doc(2048);

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

static portMUX_TYPE myMutex = portMUX_INITIALIZER_UNLOCKED;
TaskHandle_t Task1;
TaskHandle_t Task2;

void Task1code(void *parameter) {
  Serial.println(upTimeToString() + " core " + String(xPortGetCoreID()));
  MyBME680 myBME680;
  MyDHT22 myDHT22;
  MyMHZ19 myMHZ19;
  MyMICS6814 myMICS6814;
  MySGP30 mySGP30;

  while (true) {
    Serial.println(upTimeToString() + " core " + String(xPortGetCoreID()));

    if (!myDHT22.doMeasure()) networkBroadcatLog("DHT22 ERROR!", true);
    delay(10);

    if (!myBME680.doMeasure()) networkBroadcatLog("BME680 ERROR!", true);
    delay(10);

    if (!myMHZ19.doMeasure()) networkBroadcatLog("MHZ19 ERROR!", true);
    delay(10);

    if (!myMICS6814.doMeasure()) networkBroadcatLog("MICS6814 ERROR!", true);
    delay(10);

    if (!mySGP30.doMeasure()) networkBroadcatLog("SGP30 ERROR!", true);
    delay(10);

    // {
    //   JsonArray Sensors = doc.createNestedArray("Sensors");
    //   myDHT22.toJSON(Sensors);
    //   serializeJsonPretty(doc, Serial);
    // }
    {
      jsonHeader();
      // getting data and convert it into JSON
      JsonArray Sensors = doc.createNestedArray("Sensors");

      myDHT22.toJSON(Sensors);
      myBME680.toJSON(Sensors);
      myMHZ19.toJSON(Sensors);
      myMICS6814.toJSON(Sensors);
      mySGP30.toJSON(Sensors);

      portENTER_CRITICAL(&myMutex);
      jsonOutputAllsensors.clear();
      serializeJson(doc, jsonOutputAllsensors);
      portEXIT_CRITICAL(&myMutex);
    }

    {
      jsonHeader();
      // getting data and convert it into JSON
      JsonArray Sensors = doc.createNestedArray("Sensors");

      mySGP30.toJSON(Sensors);
      myDHT22.toJSON(Sensors);
      myMHZ19.toJSON(Sensors);
      myMICS6814.toJSON(Sensors);

      portENTER_CRITICAL(&myMutex);
      jsonOutputMTU1.clear();
      serializeJson(doc, jsonOutputMTU1);
      portEXIT_CRITICAL(&myMutex);
    }

    {
      jsonHeader();
      // getting data and convert it into JSON
      JsonArray Sensors = doc.createNestedArray("Sensors");

      myBME680.toJSON(Sensors);

      portENTER_CRITICAL(&myMutex);
      jsonOutputMTU2.clear();
      serializeJson(doc, jsonOutputMTU2);
      portEXIT_CRITICAL(&myMutex);
    }

    delay(100);
  }
}

void Task2code(void *parameter) {
  // while (true) {
  // };
  Serial.println(upTimeToString() + " core " + String(xPortGetCoreID()));
  Serial.println("Waiting for flag from Core " + String(xPortGetCoreID()));

  delay(20 * 1000);

  {
    // WiFiManager
    // Local intialization. Once its business is done, there is no need to keep
    // it around
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

    timer0.start();
    timer1.start();
    timer2.start();
    // timer3.start();

    sendDataToLocalNetwork();
    sendDataToFirebase();
    // delay(60*60 * 1000);

    while (true) {
      if (configMode) return;

      timer0.update();
      timer1.update();
      timer2.update();

      processUDP(readAllUDP());
    }
  }
}

void setup() {

  Serial.begin(115200);
  // Device to serial monitor feedback
  while (!Serial)
    ;

  delay(1000);
  // create a task that will be executed in the Task1code() function, with
  // priority 1 and executed on core 0
  xTaskCreatePinnedToCore(
      Task1code, /* Task function. */
      "Task1",   /* name of task. */
      10000,     /* Stack size of task */
      NULL,      /* parameter of the task */
      1,         /* priority of the task */
      &Task1,    /* Task handle to keep track of created task */
      0);        /* pin task to core 0 */
  delay(500);

  // create a task that will be executed in the Task2code() function, with
  // priority 1 and executed on core 1
  xTaskCreatePinnedToCore(
      Task2code, /* Task function. */
      "Task2",   /* name of task. */
      10000,     /* Stack size of task */
      NULL,      /* parameter of the task */
      1,         /* priority of the task */
      &Task2,    /* Task handle to keep track of created task */
      1);        /* pin task to core 1 */
  delay(500);
}

void loop() {}

void blink_LED() {
  digitalWrite(LED_BUILTIN,
               !(digitalRead(LED_BUILTIN))); // Invert Current State of LED
}

void sendDataToLocalNetwork() {
  if (jsonOutputAllsensors.isEmpty()) return;
  sendUDP(jsonOutputAllsensors);
}

void sendDataToFirebase() {
  while (jsonOutputMTU1.isEmpty()) ;
  while (jsonOutputMTU2.isEmpty()) ;
  String url =
      "https://us-central1-pfe-air-quality.cloudfunctions.net/addRecord";

  while(!httpPOST(url, jsonOutputMTU1));

  while(!httpPOST(url, jsonOutputMTU2));
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
        Serial.println("request body : " + body);
        clientHTTP.end();
        if (httpCode >= 400) {
          delay(15 * 1000);
          return false ;
          // ESP.restart();
        }
      } else {
        Serial.println("Error on HTTP request");
        Serial.println(clientHTTP.errorToString(httpCode));
        delay(5 * 1000);
        return false ;
        // ESP.restart(); // TODO: send msg + err in local network before
        // restarting
        // ....
      }
    } else {
      Serial.printf("[HTTP] Unable to connect");
      Serial.printf(url.c_str());
      return false ;
      // ESP.restart();
    }

  } else {
    Serial.println("WiFi.status() == WL_CONNECTED, no WiFi");
    return false ;
    ESP.restart(); // restart esp to connect into wifi again
                   // ....
  }
  delay(1000);
  return true;
}

void jsonHeader() {
  // clear RAM
  doc.clear();
  doc["uid"] = "Lf7gh5IDYxZgOmUXKhtaHSk6j9y2";
  doc["GPS"]["latitude"] = 35.6935229;
  doc["GPS"]["longitude"] = -0.6140395;
  doc["upTime"] = millis();
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
