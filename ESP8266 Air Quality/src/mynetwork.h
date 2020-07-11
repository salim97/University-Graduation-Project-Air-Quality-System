
#include <IPAddress.h>
#include <ESP8266WIFI.h>
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
char packetBuffer[2048]; // buffer to hold incoming packet,

// unsigned int tcpPort = 5544;  // port input data
// WiFiClient client; // tcp client
// String tcpBuffer ;

unsigned int udpPort = 9876;
WiFiUDP udp; // udp broadcast client
String udpBuffer;

String _jsonOutput;
DynamicJsonDocument _doc(2048);

void init_udp() {
  ipBroadCast = WiFi.localIP();
  ipBroadCast[3] = 255;
  udp.begin(udpPort); // set udp port for listen...
  localIP += String(WiFi.localIP()[0]);
  localIP += +"." + String(WiFi.localIP()[1]);
  localIP += +"." + String(WiFi.localIP()[2]);
  localIP += +"." + String(WiFi.localIP()[3]);
}

String readAllUDP() {
  int packetSize = udp.parsePacket();
  udpBuffer = "";
  if (packetSize) {
    // read the packet into packetBufffer
    udp.read(packetBuffer, 2048);
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

String upTimeToString() {
  static char str[12];
  unsigned long t = millis() /1000 ;
  long h = t / 3600;
  t = t % 3600;
  int m = t / 60;
  int s = t % 60;
  sprintf(str, "%04ld:%02d:%02d", h, m, s);
  return str;
}

void networkBroadcatLog(String msg, bool isError = false) {
  _doc.clear();
  _jsonOutput.clear();
  _doc["ip"] = localIP;
  _doc["upTime"] = upTimeToString();
  _doc["msg"] = msg;
  _doc["isError"] = isError;
  serializeJson(_doc, _jsonOutput);
  sendUDP(_jsonOutput);
}

