
#include "myEPPROM.h"
#include <IPAddress.h>
#include <WiFi.h>
#include <WiFiUDP.h>

/*---------------*/
// wifi config
/*----------------*/
const char *WIFI_AP_SSID = "HNA FI HNA"; // this is fine
const char *WIFI_AP_PASSWORD = NULL;     // NULL = AP with no password

//---------------------------------------------------------
// UDP/TCP packet handler
//---------------------------------------------------------
IPAddress ipBroadCast;
String localIP, remoteIP;
char packetBuffer[500]; // buffer to hold incoming packet,

// unsigned int tcpPort = 5544;  // port input data
// WiFiClient client; // tcp client
// String tcpBuffer ;

unsigned int udpPort = 9876;
WiFiUDP udp; // udp broadcast client
String udpBuffer;

String _jsonOutput;
DynamicJsonDocument _doc(2048);
bool testWiFi(String ssid, String pass);
bool am_i_the_access_point();

bool mynetwork_init() {
  EEPROM.begin(512);
  String essid = getSSID();
  String epass = getPASS();
  if (essid.length() > 1) {
    if (testWiFi(essid, epass)) {
      // debuging ...
      Serial.println("");
      Serial.print("IP Address: ");
      Serial.println(WiFi.localIP()); // todo: config ip broadcast
      ipBroadCast = WiFi.localIP();
    }
  }

  if (am_i_the_access_point()) {
    // unable to connect into the wifi
    // start config mode
    WiFi.softAP(WIFI_AP_SSID, WIFI_AP_PASSWORD);

    Serial.print("AP IP address: ");
    Serial.println( WiFi.softAPIP());
    Serial.print("ESP Board MAC Address:  ");
    Serial.println(WiFi.macAddress());
    ipBroadCast =  WiFi.softAPIP();
  }

  ipBroadCast[3] = 255;
  udp.begin(udpPort); // set udp port for listen...
  localIP += String(WiFi.localIP()[0]);
  localIP += +"." + String(WiFi.localIP()[1]);
  localIP += +"." + String(WiFi.localIP()[2]);
  localIP += +"." + String(WiFi.localIP()[3]);

  return true;
}

bool testWiFi(String ssid, String pass) {
  // start connecting to wifi....
  WiFi.begin(ssid.c_str(), pass.c_str());
  int counter = 0;
  // wait untill esp8266 connected to wifi...
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print(".");
    delay(500);
    counter++;
    if (counter == 10) {
      return false;
    }
  }
  return true;
}

bool am_i_the_access_point() {
  // WL_CONNECTED: assigned when connected to a WiFi network;
  
  return WiFi.status() != WL_CONNECTED; // false = conencted to another router, true = not connected to WiFi
}

String readAllUDP() {
  int packetSize = udp.parsePacket();
  udpBuffer = "";
  if (packetSize) {
    // read the packet into packetBufffer
    udp.read(packetBuffer, 500);
    udpBuffer = String(packetBuffer);

    for (int i = 0; i < packetSize; i++)
      packetBuffer[i] = 0;
    Serial.println("readAllUDP: " + udpBuffer);
  }

  return udpBuffer;
}

void sendUDP(String msg) {
  if (msg.length() == 0) return;

  msg += " ";
  // convert string to char array
  int UDP_PACKET_SIZE = msg.length();
  uint8_t tmpBuffer[UDP_PACKET_SIZE - 1];
  // msg.toCharArray(tmpBuffer, UDP_PACKET_SIZE) ;
  for (int i = 0; i < UDP_PACKET_SIZE; i++)
    tmpBuffer[i] = msg[i];
  //// send msg broadcast to port destinie
  udp.beginPacket(ipBroadCast, udpPort);
  udp.write(tmpBuffer, UDP_PACKET_SIZE);
  udp.endPacket();
  memset(tmpBuffer, 0, UDP_PACKET_SIZE);
  // Serial.println("sendUDP: "+msg) ;
  // Serial.println(localIP+" sendUDP: "+msg) ;

  // Serial.println(jsonOutput) ;
}

void networkBroadcatLog(String msg, bool isError = false) {
  _doc.clear();
  _jsonOutput.clear();
  _doc["ip"] = localIP;
  _doc["upTime"] = millis();
  _doc["msg"] = msg;
  _doc["isError"] = isError;
  serializeJson(_doc, _jsonOutput);
  sendUDP(_jsonOutput);
}
