#include <ArduinoJson.h>


#include <IPAddress.h>
#include <WiFiUDP.h>
#define DEBUG_SERIAL true
#define DEBUG_SERIAL_UDP false
#define DEBUG_SERIAL_TCP true


#if defined(ESP32)
#include <WiFi.h>
#include <WiFiUdp.h>
#include <esp_wifi.h>

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

#define defaultDeviceID "ESP" + _getESP32ChipID()
#endif

#if defined(ESP8266)
#include <ESP8266WIFI.h>
#define defaultDeviceID "ESP" + String(ESP.getChipId())
#endif

class MyLocalNetworkEngine {
  bool _oldTCPisConnected = false;
  IPAddress _oldClientIP;

public:
  String tcpBuffer, udpBuffer;
  IPAddress ip_local, ip_subnetMask, ip_broadcast;
  WiFiUDP udpSocket;    // udp broadcast client

  unsigned int UDP_port, TCP_port;
  String deviceUID;

  MyLocalNetworkEngine() {}
  void getNetworkInfo() {
    ip_local = WiFi.localIP();
    ip_subnetMask = WiFi.subnetMask();

    for (int i = 0; i < 4; i++) {
      ip_local[i] = String(WiFi.localIP()[i]).toInt();
      ip_subnetMask[i] = String(WiFi.subnetMask()[i]).toInt();
      ip_broadcast[i] = (byte)(ip_local[i] | (ip_subnetMask[i] ^ 255));
    }
    if (DEBUG_SERIAL) {
      Serial.println("local ip = \t" + ip_local.toString());
      Serial.println("netmask  = \t" + ip_subnetMask.toString());
      Serial.println("broadcast = \t" + ip_broadcast.toString());
    }
  }
  void begin(String deviceUID = defaultDeviceID, unsigned int UDP_port = 9876) {
    this->deviceUID = deviceUID;
    this->UDP_port = UDP_port;
    udpSocket.begin(UDP_port); // set udp port for listen...
    getNetworkInfo();
  }
  void check() {
    udpCheck();
  }

  //---------------------------------------------------------
  // UDP packet handler
  //---------------------------------------------------------
  void udpCheck() {
    if (!readAllUDP().isEmpty()) {
      DynamicJsonDocument _doc(512);
      String _jsonOutput ;
      deserializeJson(_doc, udpBuffer);
      if (_doc["command"] == "scanNetwork") {
        _doc.clear();
        _jsonOutput.clear();
        _doc["ip"] = ip_local.toString();
        _doc["upTime"] = upTimeToString();
        _doc["deviceName"] = deviceUID;
        // serializeJsonPretty(_doc, Serial);
        serializeJson(_doc, _jsonOutput);
        sendUDP(_jsonOutput);
        return;
      }
    }
  }

  void sendUDP(String msg) {
    if (msg.length() == 0) return;

    msg += " ";
    // convert string to char array
    //// send msg broadcast to port destinie
    udpSocket.beginPacket(ip_broadcast, UDP_port);
    // udp.write(tmpBuffer, UDP_PACKET_SIZE);
    // udpSocket.write(msg.c_str(), msg.length());
    udpSocket.write((const uint8_t*)msg.c_str(), msg.length());
    udpSocket.endPacket();
    if (DEBUG_SERIAL_UDP) {
      Serial.println(__func__);
      Serial.println("Sending " + String(msg.length()) + " bytes to " +
                     ip_broadcast.toString() + " , port " + UDP_port);
      Serial.println("UDP packet contents: \n" + msg);
    }
  }

  String readAllUDP() {

    int packetSize = udpSocket.parsePacket();
    char packetBuffer[packetSize + 1]; // buffer to hold incoming packet,

    udpBuffer = "";
    if (packetSize) {
      // read the packet into packetBufffer
      udpSocket.read(packetBuffer, packetSize);
      packetBuffer[packetSize] = '\0';
      udpBuffer = String(packetBuffer);
      for (int i = 0; i < packetSize; i++)
        packetBuffer[i] = 0;
      if (DEBUG_SERIAL_UDP) {
        Serial.println(__func__);
        Serial.printf("Received %d bytes from %s, port %d\n", packetSize,
                      udpSocket.remoteIP().toString().c_str(),
                      udpSocket.remotePort());
        Serial.println("UDP packet contents: " + udpBuffer);
      }
    }
    return udpBuffer;
  }

  String upTimeToString(bool timestampe = false) {
    if (timestampe) {
      return String(millis());
    }
    static char str[15];
    unsigned long t = millis() / 1000;
    long h = t / 3600;
    t = t % 3600;
    int m = t / 60;
    int s = t % 60;
    sprintf(str, "[ %04ld:%02d:%02d ]", h, m, s);
    return str;
  }
};
