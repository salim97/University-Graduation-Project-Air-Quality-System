// https://randomnerdtutorials.com/esp32-pinout-reference-gpios/
// https://arduinojson.org/v6/assistant/
// https://randomnerdtutorials.com/esp32-dual-core-arduino-ide/
// https://docs.espressif.com/projects/esp-idf/en/latest/esp32/api-guides/freertos-smp.html
// https://esp32.com/viewtopic.php?t=1703
// http://www.iotsharing.com/2017/06/how-to-use-binary-semaphore-mutex-counting-semaphore-resource-management.html
// #include "NTPClient.h"
#include <Arduino.h>
#include <ArduinoJson.h>
#include <BluetoothSerial.h>
#include <ESPAsyncWebServer.h>
#include <ESPAsyncWiFiManager.h> //https://github.com/tzapu/WiFiManager
#include <EasyButton.h>
#include <HTTPClient.h>
#include <Preferences.h>
#include <Ticker.h>
#include <WiFi.h>
#include <WiFiUdp.h>
#include <esp_wifi.h>
Preferences preferences;

//#include "co-processor.h"
#include "My_REST_API.h"
#include "mynetwork.h"
#include "MyLocalNetworkEngine.h"
#include "sensors/BME680.h"
#include "sensors/DHT22.h"
#include "sensors/MHZ19.h"
#include "sensors/MICS6814.h"
#include "sensors/MQ131.h"
#include "sensors/SGP30.h"
/*
#if defined(ESP32)
static const char _HEX_CHAR_ARRAY[17] = "0123456789ABCDEF";
static String _byteToHexString(uint8_t *buf, uint8_t length,
                               String strSeperator = "-") {
  String dataString = "";
  for (uint8_t i = 0; i < length; i++) {
    byte v = buf[i] / 16;
    byte w = buf[i] % 16;
    if (i > 0) {
      dataString += strSeperator;
    }
    dataString += String(_HEX_CHAR_ARRAY[v]);
    dataString += String(_HEX_CHAR_ARRAY[w]);
  }
  dataString.toUpperCase();
  return dataString;
} // byteToHexString
String _getESP32ChipID() {
  uint64_t chipid;
  chipid = ESP.getEfuseMac(); // The chip ID is essentially its MAC
                              // address(length: 6 bytes).
  int chipid_size = 6;
  uint8_t chipid_arr[chipid_size];
  for (uint8_t i = 0; i < chipid_size; i++) {
    chipid_arr[i] = (chipid >> (8 * i)) & 0xff;
  }
  return _byteToHexString(chipid_arr, chipid_size, "");
}

#define APName "ESP" + _getESP32ChipID();
#endif

#if defined(ESP8266)
#define APName "ESP" + String(ESP.getChipId());
#endif
*/

MySensor *mySensorsList[] = {new MyDHT22(), new MyBME680(), 
                          new MySGP30(),
                             new MyMHZ19(), new MyMICS6814()};
// new MQ131(),
//  new MyMHZ19(), new MyMICS6814()};

void FirstCoreCode(void *parameter);
void SecondCoreCode(void *parameter);
String requestBodyReady();

void blink_LED();
void sendDataToFirebase();

void processUDP(String command);
bool httpPOST(String url, String body);
void tmp_SecondCoreCode();

// REST API
void setServerConfig(AsyncWebServerRequest *request);
void getServerConfig(AsyncWebServerRequest *request);
void getSensorsData(AsyncWebServerRequest *request);

SemaphoreHandle_t xMutex;
TaskHandle_t Task1;
TaskHandle_t Task2;

// Instance of the button.
EasyButton resetFactoryButton(0);

void setup() {

  // led ON for 500msec, off for 4500msec , repeat 60 times
  // blink_while_wait_ulp(300, 300, 10);
  // init mutex
  xMutex = xSemaphoreCreateMutex();

  Serial.begin(115200);
  // Device to serial monitor feedback
  while (!Serial)
    ;

  // startulp(); //co-processor.h

  // Open Preferences with my-app namespace. Each application module, library,
  // etc has to use a namespace name to prevent key name collisions. We will
  // open storage in RW-mode (second parameter has to be false). Note: Namespace
  // name is limited to 15 chars.
  preferences.begin("firebaseConfig", false);

  // preferences.putString("requestDateTime", "requestDateTime");
  // preferences.putString("uid", "Lf7gh5IDYxZgOmUXKhtaHSk6j9y2");
  preferences.putFloat("GPS_latitude" , 35.6937001);
  preferences.putFloat("GPS_longitude",-0.6139010);


  // preferences.putFloat("GPS_latitude", 36.77712702457173);
  // preferences.putFloat("GPS_longitude",3.055592311162079);


  // preferences.putFloat("GPS_altitude", -0.61404);
  // preferences.putBool("FCR", true);
 // preferences.end();
  //  preferences.begin("firebaseConfig", true);
//   Serial.println("preferences.getString(uid):");
//   Serial.println(preferences.getString("uid"));
//   Serial.println(preferences.getFloat("GPS_latitude"));
//   Serial.println(preferences.getFloat("GPS_longitude"));
//   Serial.println(preferences.getFloat("GPS_altitude"));
// return ;

  // jsonHeader();
  // tmp_SecondCoreCode();

  // Initialize the button.
  resetFactoryButton.begin();
  // Add the callback function to be called when the button is pressed.
  resetFactoryButton.onPressed([]() {
    Serial.println("Reset Factory Button was pushed!\n");
    pinMode(LED_BUILTIN, OUTPUT);
    digitalWrite(LED_BUILTIN, LOW);

    for (int i = 0; i < 10; i++) {
      digitalWrite(LED_BUILTIN,
                   !(digitalRead(LED_BUILTIN))); // Invert Current State of LED
      delay(500);
    }
    // reset settings - for testing
    // wifiManager.resetSettings();
    WiFi.disconnect(true, true);
    preferences.clear();
    delay(100);
    ESP.restart();
  });

  delay(500);
  // create a task that will be executed in the FirstCoreCode() function, with
  // priority 1 and executed on core 0
  xTaskCreatePinnedToCore(
      FirstCoreCode, /* Task function. */
      "Task1",       /* name of task. */
      10000,         /* Stack size of task */
      NULL,          /* parameter of the task */
      1,             /* priority of the task */
      &Task1,        /* Task handle to keep track of created task */
      0);            /* pin task to core 0 */
  delay(500);

  // create a task that will be executed in the SecondCoreCode() function, with
  // priority 1 and executed on core 1
  xTaskCreatePinnedToCore(
      SecondCoreCode, /* Task function. */
      "Task2",        /* name of task. */
      10000,          /* Stack size of task */
      NULL,           /* parameter of the task */
      1,              /* priority of the task */
      &Task2,         /* Task handle to keep track of created task */
      1);             /* pin task to core 1 */
  delay(500);
}

void loop() { resetFactoryButton.read(); }

String globalSharedBuffer;

void FirstCoreCode(void *parameter) {
  Serial.println(upTimeToString() + " core " + String(xPortGetCoreID()));
  // setCoreSensorStatus(false);//co-processor.h
  const uint8_t sizeMySensorsList =
      sizeof(mySensorsList) / sizeof(mySensorsList[0]);

  for (uint8_t i = 0; i < sizeMySensorsList; i++) {
    if (!mySensorsList[i]->init()) {
      Serial.println("ALLLLEERRRTT ---------------------- : " + mySensorsList[i]->sensorName() );
      // setCoreSensorStatus (true);
    }
  }
  DynamicJsonDocument doc(4096);
  while (true) {
    Serial.println(upTimeToString() + " core " + String(xPortGetCoreID()));
    // bool oneSensorIsDown = false;
    for (uint8_t i = 0; i < sizeMySensorsList; i++) {
      if (!mySensorsList[i]->doMeasure()) {
        Serial.println("ALLLLEERRRTT ---------------------- : " + mySensorsList[i]->sensorName() );
        // setCoreSensorStatus(true);
      }
      // oneSensorIsDown = oneSensorIsDown || !mySensorsList[i]->doMeasure();
    }
    // setCoreSensorStatus(oneSensorIsDown);//co-processor.h

    doc.clear();
    // jsonHeader();
    // getting data and convert it into JSON
    JsonArray Sensors = doc.createNestedArray("Sensors");
    for (uint8_t i = 0; i < sizeMySensorsList; i++) {
      mySensorsList[i]->toJSON(Sensors);
    }

    xSemaphoreTake(xMutex, portMAX_DELAY);
    globalSharedBuffer.clear();
    serializeJson(doc, globalSharedBuffer);
    xSemaphoreGive(xMutex);

    delay(100);
  }
}

// each second blink led
Ticker timer0(blink_LED, 5 * 1000);
// each 10 min send data to server
Ticker timer1(sendDataToFirebase, 10 * 60 * 1000);

bool configMode = false;
void configModeCallback(AsyncWiFiManager *myWiFiManager) {
  Serial.println("Entered config mode");
  Serial.println(WiFi.softAPIP());
  // if you used auto generated SSID, print it
  Serial.println(myWiFiManager->getConfigPortalSSID());
  configMode = true;
  // setDeviceStatus(DeviceStatus::waitingForWiFiConfig);//co-processor.h
}
void saveConfigCallback() {
  Serial.println("-----------------------------------------------------");
  Serial.println("Should save config");
  configMode = false;
}
AsyncWebServer server(80);
DNSServer dns;
void SecondCoreCode(void *parameter) {

  Serial.println(upTimeToString() + " core " + String(xPortGetCoreID()));
  // setDeviceStatus(DeviceStatus::booting);//co-processor.h
  {
    // BluetoothSerial ESP_BT;            // Object for Bluetooth
    // ESP_BT.begin("Trash Binome :)"); // Name of your Bluetooth Signal
    // Serial.println("Bluetooth Device is Ready to Pair");

    AsyncWiFiManager wifiManager(&server, &dns);
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
      delay(1000);
      ESP.restart();
    }

    // if you get here you have connected to the WiFi
    wifi_config_t conf;
    esp_wifi_get_config(WIFI_IF_STA, &conf);
    Serial.println("SSID: " +
                   String(reinterpret_cast<const char *>(conf.sta.ssid)));
    Serial.println("PASS: " +
                   String(reinterpret_cast<const char *>(conf.sta.password)));
    // while (configMode) ;

    init_udp();
    // pinMode(BUILTIN_LED, OUTPUT);
    // pinMode(LED_BUILTIN, OUTPUT);
    // blink_LED();

    server.end();
    server.on("/status", HTTP_GET, getESP8266status);
    server.on("/sensors", HTTP_GET, getSensorsData);
    server.on("/serverConfig", HTTP_POST, setServerConfig);
    server.on("/serverConfig", HTTP_GET, getServerConfig);

    server.onNotFound([](AsyncWebServerRequest *request) {
      request->send(404, "text/plain", "Not found");
    });
    server.begin();
    MyLocalNetworkEngine myLocalNetworkEngine;
    myLocalNetworkEngine.begin();
    // while (preferences.getBool("FCR", false) == false) {
    //   processUDP(readAllUDP());
    //   Serial.println(upTimeToString() + " core " + String(xPortGetCoreID()) +
    //                  ": Waiting for firebase config from local network");
    //   delay(1000);
    //   // setDeviceStatus(DeviceStatus::waitingForServerConfig);//co-processor.h
    // }
    // setDeviceStatus(DeviceStatus::everythingIsOK);//co-processor.h
    // ulp_set_led_on_delay(2000);
    // ulp_set_led_off_delay(2000);

    while (true) {
      Serial.println(upTimeToString() + " core " + String(xPortGetCoreID()) +
                     ": Waiting for flag from Core 0");
      xSemaphoreTake(xMutex, portMAX_DELAY);
      if (!globalSharedBuffer.isEmpty()) {
        xSemaphoreGive(xMutex);
        break;
      }
      xSemaphoreGive(xMutex);
      delay(1000);
    };

    // timer0.start();
    timer1.start();


    sendDataToFirebase();

    while (true) {
      timer1.update();
      myLocalNetworkEngine.udpCheck();
    }
  }
}

void blink_LED() {
  digitalWrite(LED_BUILTIN,
               !(digitalRead(LED_BUILTIN))); // Invert Current State of LED
  networkBroadcatLog(digitalRead(LED_BUILTIN) ? "BILTIN LED is ON"
                                              : "BILTIN LED is OFF");
  //  networkBroadcatLog("led is blinking", false);
}

void sendDataToFirebase() {
  // return ;
  // String url = "https://pfe-helper.herokuapp.com/";
  String url =
      "https://us-central1-pfe-air-quality.cloudfunctions.net/addRecord";
  // "https://postman-echo.com/post";

  while (!httpPOST(url, requestBodyReady()))
    ;
}

bool httpPOST(String url, String body) {
    return true; // TODO: remove this line
  if (WiFi.status() == WL_CONNECTED) {

    HTTPClient clientHTTP;

    if (clientHTTP.begin(url)) {
      Serial.println("connected: " + url);
      clientHTTP.addHeader("Content-Type", "application/json");
      int httpCode = clientHTTP.POST(body);
      if (httpCode > 0) {
        String payload = clientHTTP.getString();
        Serial.println(payload);
        Serial.println("Status code : " + String(httpCode));
        Serial.println("request body : " + body);
        clientHTTP.end();

        if (httpCode >= 400) {
          networkBroadcatLog("HTTP Response Code : " + String(httpCode) +
                                 "\n HTTP Response Body : " + payload,
                             true);
          delay(5 * 1000);
          return false;
        } else {
          networkBroadcatLog("HTTP Response Code : " + String(httpCode) +
                                 "\n HTTP Response Body : " + payload,
                             false);
        }

      } else {

        networkBroadcatLog("HTTP Internal Error Code : " + String(httpCode) +
                               "\n HTTP Internal Error Message : " +
                               clientHTTP.errorToString(httpCode),
                           true);
        delay(5 * 1000);
        return false;
      }
    } else {
      networkBroadcatLog("HTTP Unable to connect : " + url, true);
      return false;
    }

  } else {
    Serial.println("WiFi.status() == WL_CONNECTED, no WiFi");
    delay(5 * 1000);
    ESP.restart(); // restart esp to connect into wifi again
                   // ....
  }
  delay(1000);
  return true;
}

String requestBodyReady() {
  String requestBodyReady;
  DynamicJsonDocument doc(4096);
  DeserializationError e;
  xSemaphoreTake(xMutex, portMAX_DELAY);
  e = deserializeJson(doc, globalSharedBuffer);
  xSemaphoreGive(xMutex);
  Serial.println(e.c_str());
  doc["uid"] = preferences.getString("uid");
  doc["GPS"]["latitude"] = preferences.getFloat("GPS_latitude");
  doc["GPS"]["longitude"] = preferences.getFloat("GPS_longitude");
  doc["upTime"] = millis();
  serializeJsonPretty(doc, requestBodyReady);
  Serial.println("------------------------------------------------");
  Serial.println(requestBodyReady);
  Serial.println("------------------------------------------------");

  return requestBodyReady;
}

// void processUDP(String command) {
//   DynamicJsonDocument _doc(512);
//   deserializeJson(_doc, command);
//   if (_doc["command"] == "scanNetwork") {
//     String __jsonOutput;
//     DynamicJsonDocument __doc(4096);

//     __doc.clear();
//     __jsonOutput.clear();
//     __doc["ip"] = localIP;
//     __doc["upTime"] = upTimeToString();
//     __doc["deviceName"] = APName;
//     serializeJsonPretty(__doc, Serial);
//     serializeJson(__doc, __jsonOutput);
//     sendUDP(__jsonOutput);
//     delay(500);
//     return;
//   }
// }

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

  // const char *requestDateTime = _doc["requestDateTime"]; // "setData"
  // preferences.putString("requestDateTime", requestDateTime);
  const char *uid = _doc["uid"]; // "Lf7gh5IDYxZgOmUXKhtaHSk6j9y2"
  preferences.putString("uid", uid);
  preferences.putFloat("GPS_latitude", _doc["latitude"]);
  preferences.putFloat("GPS_longitude", _doc["longitude"]);
  preferences.putFloat("GPS_altitude", _doc["altitude"]);
  preferences.putBool("FCR", true);

  serializeJsonPretty(_doc, _jsonOutput);
  // myServerConfig.setServerConfig(_jsonOutput);
  request->send(200, "text/plain", _jsonOutput);
}

void getServerConfig(AsyncWebServerRequest *request) {

  String _jsonOutput;
  DynamicJsonDocument _doc(1024);
  _doc["uid"] = preferences.getString("uid");
  _doc["GPS_latitude"] = preferences.getFloat("GPS_latitude");
  _doc["GPS_longitude"] = preferences.getFloat("GPS_longitude");
  _doc["GPS_altitude"] = preferences.getFloat("GPS_altitude");

  serializeJsonPretty(_doc, _jsonOutput);

  if (_jsonOutput.isEmpty())
    request->send(400, "text/plain", "Server Config is empty");
  else
    request->send(200, "text/plain", _jsonOutput);
}

void getSensorsData(AsyncWebServerRequest *request) {
  String local;
  xSemaphoreTake(xMutex, portMAX_DELAY);
  local = globalSharedBuffer;
  xSemaphoreGive(xMutex);
  DynamicJsonDocument doc(4096);
  DeserializationError e;
  e = deserializeJson(doc, local);
  local.clear();
  serializeJsonPretty(doc, local);


  if (local.isEmpty())
    request->send(400, "text/plain",
                  "sensor data is empty, check your sensors!");
  else
    request->send(200, "text/plain", local);
}

// void tmp_SecondCoreCode() {

//   AsyncWiFiManager wifiManager(&server, &dns);

//   wifiManager.setAPCallback(configModeCallback);
//   wifiManager.setSaveConfigCallback(saveConfigCallback);

//   if (!wifiManager.autoConnect()) {
//     Serial.println("failed to connect and hit timeout");
//     ESP.restart();
//     delay(1000);
//   }

//   wifi_config_t conf;
//   esp_wifi_get_config(WIFI_IF_STA, &conf);
//   Serial.println("SSID: " +
//                  String(reinterpret_cast<const char *>(conf.sta.ssid)));
//   Serial.println("PASS: " +
//                  String(reinterpret_cast<const char *>(conf.sta.password)));

//   init_udp();
//   pinMode(LED_BUILTIN, OUTPUT);
//   blink_LED();

//   while (true) {
//     processUDP(readAllUDP());
//   }
// }