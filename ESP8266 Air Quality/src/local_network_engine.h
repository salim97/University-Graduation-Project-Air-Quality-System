#include <ArduinoJson.h>
#include <ESP8266WIFI.h>
#include <IPAddress.h>
#include <WiFiUDP.h>
String _jsonOutput;
DynamicJsonDocument _doc(2048);
class LocalNetworkEngine {
  //---------------------------------------------------------
  // UDP/TCP packet handler
  //---------------------------------------------------------
  IPAddress ipBroadCast;
  String localIP, remoteIP;
  char packetBuffer[2048]; // buffer to hold incoming packet,

  // unsigned int tcpPort = 5544;  // port input data
  // WiFiClient client; // tcp client
  // String tcpBuffer ;
  WiFiUDP udp;       // udp broadcast client
  WiFiClient client; // tcp client

  WiFiServer server(9876);

  String tcpBuffer, udpBuffer;

  unsigned int UDP_port, TCP_port;

public:
  LocalNetworkEngine(unsigned int UDP_port = 9876,
                     unsigned int TCP_port = 9876) {
    this->UDP_port = UDP_port;
    this->TCP_port = TCP_port;
    ipBroadCast = WiFi.localIP();
    ipBroadCast[3] = 255;
    udp.begin(UDP_port); // set udp port for listen...
    localIP += String(WiFi.localIP()[0]);
    localIP += +"." + String(WiFi.localIP()[1]);
    localIP += +"." + String(WiFi.localIP()[2]);
    localIP += +"." + String(WiFi.localIP()[3]);
    server.begin(TCP_port);
  }
  void loop() {
    if (!isConnected()) {
      client = server.available();
    }

    if (isConnected()) {

      String tmp = readAllTCP();
      sendTCP("9awed");
    }
  }

  void closeConnection() {
    client.stop();
    Serial.println("Client disconnected");
  }

  bool isConnected() {
    if (client) {
      if (client.connected()) {
        Serial.println("Client Connected");
        return true;
      }
    }
    return false;
  }

  // it should be bool and not void because TCP ....
  void sendTCP(String msg) {
    if (msg.length() == 0) return;
    if (isConnected()) client.print(msg);

    // Serial.println("sendTCP: "+msg) ;
  }
  String readAllTCP() {
    tcpBuffer = "";
    if (isConnected()) {
      while (client.available()) {
        char c = client.read();
        tcpBuffer += c;
      }
      // Serial.println("readAllTCP: "+tcpBuffer) ;
    }
    return tcpBuffer;
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
};
