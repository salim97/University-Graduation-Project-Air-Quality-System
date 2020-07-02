
#include <Arduino.h>
#include <EEPROM.h>

#define EPPROM_SSID_FROM 0
#define EPPROM_SSID_TO 32
#define EPPROM_PASS_FROM 32
#define EPPROM_PASS_TO 96

void myEEPROMcommit()
{
  if (EEPROM.commit()) Serial.println("ERROR while writing in EPPROM");
}

String getSSID() {
  Serial.println("Reading EEPROM ssid");
  String esid;
  for (int i = EPPROM_SSID_FROM; i < EPPROM_SSID_TO; ++i) {
    esid += char(EEPROM.read(i));
  }
  Serial.print("SSID: ");
  Serial.println(esid);
  return esid;
}

void setSSID(String ssid) {
  Serial.println("writing eeprom ssid:");
  for (int i = 0; i < ssid.length(); ++i) {
    EEPROM.write(i, ssid[i]);
    Serial.print("Wrote: ");
    Serial.println(ssid[i]);
  }
  myEEPROMcommit();
}

String getPASS() {
  Serial.println("Reading EEPROM pass");
  String epass = "";
  for (int i = EPPROM_PASS_FROM; i < EPPROM_PASS_TO; ++i) {
    epass += char(EEPROM.read(i));
  }
  Serial.print("PASS: ");
  Serial.println(epass);

  return epass;
}

void setPASS(String pass) {
  Serial.println("writing eeprom pass:");
  for (int i = 0; i < pass.length(); ++i) {
    EEPROM.write(32 + i, pass[i]);
    Serial.print("Wrote: ");
    Serial.println(pass[i]);
  }
  myEEPROMcommit();
}

void clearEPPROM() {
  for (int i = 0; i < EPPROM_PASS_TO; ++i) {
    EEPROM.write(i, 0);
  }
  myEEPROMcommit();
}
