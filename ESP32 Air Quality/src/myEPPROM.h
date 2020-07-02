#include <Arduino.h>
#include <EEPROM.h>

#define EPPROM_SSID_FROM 0
#define EPPROM_SSID_TO 32
#define EPPROM_PASS_FROM 32
#define EPPROM_PASS_TO 96

String getSSID() 
{
  Serial.println("Reading EEPROM ssid");
  String esid;
  for (int i = EPPROM_SSID_FROM; i < EPPROM_SSID_TO; ++i) {
    esid += char(EEPROM.read(i));
  }
  Serial.print("SSID: ");
  Serial.println(esid);
  return esid;
}

String getPASS() 
{
  Serial.println("Reading EEPROM pass");
  String epass = "";
  for (int i = EPPROM_PASS_FROM; i < EPPROM_PASS_TO; ++i) {
    epass += char(EEPROM.read(i));
  }
  Serial.print("PASS: ");
  Serial.println(epass);

  return epass;
}

void clearEPPROM()
 {
  for (int i = 0; i < EPPROM_PASS_TO; ++i) {
    EEPROM.write(i, 0);
  }
  EEPROM.commit();
}