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
#include <HTTPClient.h>
#include <Preferences.h>
#include <Ticker.h>
#include <WiFi.h>
#include <WiFiUdp.h>
#include <esp_wifi.h>
Preferences preferences;


#include "mynetwork.h"
#include "sensors/BME680.h"
#include "sensors/DHT22.h"
#include "sensors/MHZ19.h"
#include "sensors/MICS6814.h"
#include "sensors/MQ131.h"
#include "sensors/SGP30.h"
#include "co-processor.h"
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

MySensor *mySensorsList[] = {new MQ131(),new MyDHT22(), new MyBME680(), new MySGP30(),
                             new MyMHZ19(), new MyMICS6814() };
                            //  new MyMHZ19(), new MyMICS6814()};


void FirstCoreCode(void *parameter);
void SecondCoreCode(void *parameter);
String requestBodyReady();

void blink_LED();
void sendDataToFirebase();
void sendDataToLocalNetwork();
void processUDP(String command);
bool httpPOST(String url, String body);
void tmp_SecondCoreCode();

SemaphoreHandle_t xMutex;
TaskHandle_t Task1;
TaskHandle_t Task2;

SemaphoreHandle_t semaphore = nullptr;
void IRAM_ATTR isr() { xSemaphoreGiveFromISR(semaphore, NULL); }
void resetFactoryButton(void *parameter) {
// TODO : hold 2 seconds
  // Create a binary semaphore
  semaphore = xSemaphoreCreateBinary();
  pinMode(0, INPUT);
  // Trigger the interrupt when going from HIGH -> LOW ( == pushing button)
  attachInterrupt(0, isr, FALLING);
  for (;;) {
    if (xSemaphoreTake(semaphore, portMAX_DELAY) == pdTRUE) {
      Serial.println("Reset Factory Button was pushed!\n");
      pinMode(LED_BUILTIN, OUTPUT);
      digitalWrite(LED_BUILTIN, LOW);

      for (int i = 0; i < 10; i++) {
        digitalWrite(
            LED_BUILTIN,
            !(digitalRead(LED_BUILTIN))); // Invert Current State of LED
        delay(500);
      }
      // reset settings - for testing
      // wifiManager.resetSettings();
      WiFi.disconnect(true, true);
      preferences.clear();
      delay(100);
      ESP.restart();
    }
  }
}

void setup() {

  // led ON for 500msec, off for 4500msec , repeat 60 times
  // blink_while_wait_ulp(300, 300, 10);
  // init mutex
  xMutex = xSemaphoreCreateMutex();

  Serial.begin(115200);
  // Device to serial monitor feedback
  while (!Serial)
    ;
  // pinMode(27, INPUT);
  // while(true)
  // {
  //   Serial.println(analogRead(27));
  //   delay(100);
  // }
  startulp();
  // RTC_SLOW_MEM[0] = 1U;

  // while (true) {
  //   RTC_SLOW_MEM[1] = 0U;
  //   delay(1000);
  //   RTC_SLOW_MEM[1] = 1U;
  //   delay(1000);
  //   RTC_SLOW_MEM[2] = 0U;
  //   delay(1000);
  //   RTC_SLOW_MEM[2] = 1U;
  //   delay(1000);
  //   RTC_SLOW_MEM[3] = 0U;
  //   delay(1000);
  //   RTC_SLOW_MEM[3] = 1U;
  //   delay(1000);
  // }
  // Open Preferences with my-app namespace. Each application module, library,
  // etc has to use a namespace name to prevent key name collisions. We will
  // open storage in RW-mode (second parameter has to be false). Note: Namespace
  // name is limited to 15 chars.
  preferences.begin("firebaseConfig", false);
  // jsonHeader();
  // tmp_SecondCoreCode();

  // Associate button_task method as a callback
  xTaskCreate(resetFactoryButton, "resetFactoryButton", 4096, NULL, 10, NULL);

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

void loop() {}

String globalSharedBuffer;

void FirstCoreCode(void *parameter) {
  Serial.println(upTimeToString() + " core " + String(xPortGetCoreID()));
  setCoreSensorStatus(false);
  const uint8_t sizeMySensorsList =
      sizeof(mySensorsList) / sizeof(mySensorsList[0]);

  for (uint8_t i = 0; i < sizeMySensorsList; i++) {
    if (!mySensorsList[i]->init()) {
      Serial.println("ALLLLEERRRTT ----------------------");
      setCoreSensorStatus(true);
    }
  }
  DynamicJsonDocument doc(4096);
  while (true) {
    Serial.println(upTimeToString() + " core " + String(xPortGetCoreID()));
    bool oneSensorIsDown = false ;
    for (uint8_t i = 0; i < sizeMySensorsList; i++) {
      // mySensorsList[i]->doMeasure();
      if (!mySensorsList[i]->doMeasure()) {
        Serial.println("ALLLLEERRRTT ----------------------");
        // setCoreSensorStatus(true);
      }
      // if(!mySensorsList[i]->doMeasure())
      // setCoreSensorStatus( true);
      oneSensorIsDown =  oneSensorIsDown || !mySensorsList[i]->doMeasure() ;
    }
     setCoreSensorStatus( oneSensorIsDown);

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
  setDeviceStatus(DeviceStatus::waitingForWiFiConfig);
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
  setDeviceStatus(DeviceStatus::booting);
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

    while (preferences.getBool("FCR", false) == false) {
      processUDP(readAllUDP());
      Serial.println(upTimeToString() + " core " + String(xPortGetCoreID()) +
                     ": Waiting for firebase config from local network");
      delay(1000);
      setDeviceStatus(DeviceStatus::waitingForServerConfig);
    }
    setDeviceStatus(DeviceStatus::everythingIsOK);
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

    sendDataToLocalNetwork();
    sendDataToFirebase();
    // int incoming ;
    while (true) {

      // if (configMode) continue;

      // if (ESP_BT.available()) // Check if we receive anything from Bluetooth
      // {
      //   incoming = ESP_BT.read(); // Read what we recevive
      //   Serial.print("Received:");
      //   Serial.println(incoming);

      //   if (incoming == 49) {
      //     digitalWrite(LED_BUILTIN, HIGH);
      //     ESP_BT.println("LED turned ON");
      //   }

      //   if (incoming == 48) {
      //     digitalWrite(LED_BUILTIN, LOW);
      //     ESP_BT.println("LED turned OFF");
      //   }
      // }
      // timer0.update();
      timer1.update();

      processUDP(readAllUDP());
    }
  }
}

void blink_LED() {
  digitalWrite(LED_BUILTIN,
               !(digitalRead(LED_BUILTIN))); // Invert Current State of LED
  networkBroadcatLog(digitalRead(LED_BUILTIN) ? "BILTIN LED is ON"
                                              : "BILTIN LED is OFF");
  //  networkBroadcatLog("sowa", false);
}

void sendDataToFirebase() {

  String url = "https://pfe-helper.herokuapp.com/";
  // String url =
  // "https://us-central1-pfe-air-quality.cloudfunctions.net/addRecord";
  // "https://postman-echo.com/post";

  while (!httpPOST(url, requestBodyReady()))
    ;
}

bool httpPOST(String url, String body) {
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
  serializeJson(doc, requestBodyReady);
  Serial.println(requestBodyReady.length());

  return requestBodyReady;
}

void processUDP(String command) {
  DynamicJsonDocument _doc(512);
  deserializeJson(_doc, command);
  if (_doc["command"] == "getData") {
    sendDataToLocalNetwork();
    return;
  }
  if (_doc["command"] == "scanNetwork") {
    String __jsonOutput;
    DynamicJsonDocument __doc(4096);

    __doc.clear();
    __jsonOutput.clear();
    __doc["ip"] = localIP;
    __doc["upTime"] = upTimeToString();
    __doc["deviceName"] = APName;
    serializeJsonPretty(__doc, Serial);
    serializeJson(__doc, __jsonOutput);
    sendUDP(__jsonOutput);
    delay(500);
    return;
  }
  if (_doc["command"] == "setData") {
    const char *requestDateTime = _doc["requestDateTime"]; // "setData"
    const char *uid = _doc["uid"]; // "Lf7gh5IDYxZgOmUXKhtaHSk6j9y2"
    preferences.putString("requestDateTime", requestDateTime);
    preferences.putString("uid", uid);
    preferences.putFloat("GPS_latitude", _doc["GPS"]["latitude"]);
    preferences.putFloat("GPS_longitude", _doc["GPS"]["longitude"]);
    preferences.putFloat("GPS_altitude", _doc["GPS"]["altitude"]);
    preferences.putBool("FCR", true);
    Serial.println(preferences.getString("requestDateTime"));
    Serial.println(preferences.getString("uid"));
    Serial.println(preferences.getFloat("GPS_latitude"));
    Serial.println(preferences.getFloat("GPS_longitude"));
    Serial.println(preferences.getFloat("GPS_altitude"));
    setDeviceStatus(DeviceStatus::booting);
    delay(1000);
    setDeviceStatus(DeviceStatus::everythingIsOK);

    String __jsonOutput;
    DynamicJsonDocument __doc(4096);
    __doc.clear();
    __jsonOutput.clear();
    __doc["ip"] = localIP;
    __doc["upTime"] = upTimeToString();
    __doc["deviceName"] = APName;
    __doc["lastRequest"] = true;
    serializeJsonPretty(__doc, Serial);
    serializeJson(__doc, __jsonOutput);
    sendUDP(__jsonOutput);
    // jsonHeader();
  }
}

void sendDataToLocalNetwork() {
  String local;
  xSemaphoreTake(xMutex, portMAX_DELAY);
  local = globalSharedBuffer;
  xSemaphoreGive(xMutex);
  if (local.isEmpty()) return;
  sendUDP(local);
  
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