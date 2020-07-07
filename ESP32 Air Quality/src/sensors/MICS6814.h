#include <ArduinoJson.h>
#include "../lib/MICS6814.h"

#define PIN_CO 32  // ADC1_CHANNEL_4
#define PIN_NO2 34 // ADC1_CHANNEL_6
#define PIN_NH3 35 // ADC1_CHANNEL_7
MICS6814 mics6814(PIN_CO, PIN_NO2, PIN_NH3);

void MICS6814_init()
{
  Serial.println(F("start calibrating MICS6814 ..."));
  mics6814.calibrate();
}

bool MICS6814_measure(DynamicJsonDocument &doc)
{
  Serial.println("============= MICS6814 =============");

  doc["MICS6814"]["NO2"]["value"] = mics6814.measure(NO2);
  doc["MICS6814"]["NO2"]["type"] = "PPM";
  doc["MICS6814"]["NO2"]["isCalibrated"] = true;

  doc["MICS6814"]["NH3"]["value"] = mics6814.measure(NH3);
  doc["MICS6814"]["NH3"]["type"] = "PPM";
  doc["MICS6814"]["NH3"]["isCalibrated"] = true;

  doc["MICS6814"]["CO"]["value"] = mics6814.measure(CO);
  doc["MICS6814"]["CO"]["type"] = "PPM";
  doc["MICS6814"]["CO"]["isCalibrated"] = true;

  return true;
}