// https://arduinojson.org/v6/assistant/

#include <Arduino.h>
#include <ESP8266WIFI.h>
#include <ESP8266HTTPClient.h>
#include <WiFiClient.h>

#include <Ticker.h> //Ticker Library

#include "sensors/DHT11.h"


#include "mynetwork.h"

String jsonOutput;
DynamicJsonDocument doc(2048);

void blink_LED();
void sendDataToFirebase();
void sendDataToLocalNetwork();

Ticker timer0(blink_LED, 1000);                    // each second blink led
Ticker timer1(sendDataToFirebase, 10 * 60 * 1000); // each 10 min send data to server
Ticker timer2(sendDataToLocalNetwork, 15 * 1000);  // each 10 second send data in local network

char WIFI_SSID[] = "idoomAdsl01";             // this is fine
const char *WIFI_PASSWORD = "builder2019cpp"; // this is fine
void setupWiFi();

void setup()
{
  Serial.begin(115200);
  // Device to serial monitor feedback
  while (!Serial)
    ;

  setupWiFi();

  pinMode(LED_BUILTIN, OUTPUT);


  DHT11_init();


  timer0.start();
  timer1.start();
  timer2.start();

  // sendDataToLocalNetwork();
  sendDataToFirebase();
}

void setupWiFi()
{
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to Wi-Fi");
  while (WiFi.status() != WL_CONNECTED)
  {
    Serial.print(".");
    delay(300);
  }
  Serial.println();
  Serial.println(WIFI_PASSWORD);
  Serial.print("Connected with IP: ");
  Serial.println(WiFi.localIP());
  Serial.println();
}

void loop()
{
  timer0.update();
  timer1.update();
  timer2.update();
}

void blink_LED()
{
  digitalWrite(LED_BUILTIN, !(digitalRead(LED_BUILTIN))); //Invert Current State of LED
}

void sendDataToLocalNetwork()
{
  //clear RAM
  doc.clear();
  jsonOutput.clear();
  doc["GPS"]["latitude"]["value"] = 35.6935229;
  doc["GPS"]["longitude"]["value"] = -0.6140395;

  // getting data and convert it into JSON
  DHT11_measure(doc);
  delay(10);

  //print data in serial port
  serializeJsonPretty(doc, Serial);
}

void sendDataToFirebase()
{

  //clear RAM
  doc.clear();
  jsonOutput.clear();
  doc["GPS"]["latitude"]["value"] = 35.6935229;
  doc["GPS"]["longitude"]["value"] = -0.6140395;
   // getting data and convert it into JSON
  DHT11_measure(doc);
  delay(10);

  if (WiFi.status() == WL_CONNECTED)
  {
    HTTPClient clientHTTP;
    // clientHTTP.begin("http://192.168.1.103:5001/food-delivery-2020/us-central1/webApi/api/v1/postData");
    clientHTTP.begin("http://us-central1-pfe-air-quality.cloudfunctions.net/webApi/api/v1/postData");
    clientHTTP.addHeader("Content-Type", "application/json");

    // const size_t CAPACITY = JSON_OBJECT_SIZE(1);
    // StaticJsonDocument<200> doc;

    serializeJson(doc, jsonOutput);
    int httpCode = clientHTTP.POST(String(jsonOutput));

    if (httpCode > 0)
    {
      String payload = clientHTTP.getString();
      Serial.println("Status code : " + String(httpCode));
      Serial.println(payload);
      clientHTTP.end();
    }
    else
    {
      Serial.println("Error on HTTP request");
      ESP.restart(); //TODO: send msg + err in local network before restarting ....
    }
  }
  else
  {
    Serial.println("Connection lost");
    ESP.restart(); //TODO: send msg + err in local network before restarting ....
  }
  delay(1000);
}
