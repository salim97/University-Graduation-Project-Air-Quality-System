
#include <IPAddress.h>
#include <WiFiUDP.h>
#include <WiFi.h>

/*---------------*/
// wifi config
/*----------------*/
const char *WIFI_SSID = "idoomAdsl01";        // this is fine
// const char *WIFI_SSID = "abc";        // this is fine
const char *WIFI_PASSWORD = "builder2019cpp"; // this is fine
// const char *WIFI_PASSWORD = "ustousto"; // this is fine

//---------------------------------------------------------
// UDP/TCP packet handler
//---------------------------------------------------------
IPAddress ipBroadCast;
String localIP, remoteIP;
char packetBuffer[500]; //buffer to hold incoming packet,

// unsigned int tcpPort = 5544;  // port input data
// WiFiClient client; // tcp client
// String tcpBuffer ;

unsigned int udpPort = 9876;
WiFiUDP udp; // udp broadcast client
String udpBuffer;

String _jsonOutput;
DynamicJsonDocument _doc(2048);

bool mynetwork_init()
{
  //start connecting to wifi....
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  // wait untill esp8266 connected to wifi...
  while (WiFi.status() != WL_CONNECTED)
  {
    Serial.print(".");
    delay(500);
  }
  // debuging ...
  Serial.println("");
  Serial.print("IP Address: ");
  Serial.println(WiFi.localIP()); // todo: config ip broadcast

  ipBroadCast = WiFi.localIP();
  ipBroadCast[3] = 255;
  udp.begin(udpPort); // set udp port for listen...
  localIP += String(WiFi.localIP()[0]);
  localIP += +"." + String(WiFi.localIP()[1]);
  localIP += +"." + String(WiFi.localIP()[2]);
  localIP += +"." + String(WiFi.localIP()[3]);

  return true;
}

String readAllUDP()
{
  int packetSize = udp.parsePacket();
  udpBuffer = "";
  if (packetSize)
  {
    // read the packet into packetBufffer
    udp.read(packetBuffer, 500);
    udpBuffer = String(packetBuffer);

    for (int i = 0; i < packetSize; i++)
      packetBuffer[i] = 0;
     Serial.println("readAllUDP: "+udpBuffer) ;
  }

  return udpBuffer;
}

void sendUDP(String msg)
{
  if (msg.length() == 0)
    return;

  msg += " ";
  // convert string to char array
  int UDP_PACKET_SIZE = msg.length();
  uint8_t tmpBuffer[UDP_PACKET_SIZE - 1];
  //msg.toCharArray(tmpBuffer, UDP_PACKET_SIZE) ;
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

void networkBroadcatLog(String msg, bool isError = false)
{
  _doc.clear();
  _jsonOutput.clear();
  _doc["ip"] = localIP;
  _doc["upTime"] = millis();
  _doc["msg"] = msg;
  _doc["isError"] = isError;
  serializeJson(_doc, _jsonOutput);
  sendUDP(_jsonOutput);
}
