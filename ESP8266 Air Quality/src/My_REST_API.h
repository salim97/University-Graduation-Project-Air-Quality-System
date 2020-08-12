#include <ArduinoJson.h>
#include <AsyncJson.h>
#include <ESPAsyncWebServer.h>

//  https://support.randomsolutions.nl/827069-Best-dBm-Values-for-Wifi
const int RSSI_MAX = -50;  // define maximum strength of signal in dBm
const int RSSI_MIN = -100; // define minimum strength of signal in dBm
int dBmtoPercentage(int dBm) {
  int quality;
  if (dBm <= RSSI_MIN) {
    quality = 0;
  } else if (dBm >= RSSI_MAX) {
    quality = 100;
  } else {
    quality = 2 * (dBm + 100);
  }

  return quality;
}

void getESP8266status(AsyncWebServerRequest *request) {
  DynamicJsonDocument _doc(512);
  String _jsonOutput;

  _doc["SSID"] = WiFi.SSID();
  _doc["RSSI"]["dBm"] = WiFi.RSSI();
  _doc["RSSI"]["value"] = dBmtoPercentage(WiFi.RSSI());
  _doc["RSSI"]["metric"] = "%";
  _doc["RSSI"]["description"] = "Signal strength";
  _doc["VCC"]["value"] = String((float)ESP.getVcc() / 19860, 3);
  _doc["VCC"]["metric"] = "mV";
  _doc["CpuFreq"]["value"] = ESP.getCpuFreqMHz();
  _doc["CpuFreq"]["metric"] = "MHz";

  // serializeJsonPretty(_doc, Serial);
  // serializeJson(_doc, _jsonOutput);
  serializeJsonPretty(_doc, _jsonOutput);

  String body = _jsonOutput;

  request->send(200, "text/plain", body);
}
