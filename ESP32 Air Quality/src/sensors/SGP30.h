#include <ArduinoJson.h>
#include "Adafruit_SGP30.h"

Adafruit_SGP30 sgp;

void SGP30_init()
{
  if (!sgp.begin())
  {
    Serial.println("Failed to start SGP30 gas sensor - check wiring.");
    while (1)
      ;
  }
  Serial.print("Found SGP30 serial #");
  Serial.print(sgp.serialnumber[0], HEX);
  Serial.print(sgp.serialnumber[1], HEX);
  Serial.println(sgp.serialnumber[2], HEX);

  // If you have a baseline measurement from before you can assign it to start, to 'self-calibrate'
  //sgp.setIAQBaseline(0x8E68, 0x8F41);  // Will vary for each sensor!
}

bool 

SGP30_measure(DynamicJsonDocument &doc)
{
  Serial.println("============= SGP30 =============");

  if (!sgp.IAQmeasure())
  {
    Serial.println("Measurement failed :(");
    return false;
  }

  doc["SGP30"]["TVOC"]["value"] = sgp.TVOC;
  doc["SGP30"]["TVOC"]["type"] = "PPB";
  doc["SGP30"]["TVOC"]["isCalibrated"] = true;

  doc["SGP30"]["eCO2"]["value"] = sgp.eCO2;
  doc["SGP30"]["eCO2"]["type"] = "PPM";
  doc["SGP30"]["eCO2"]["isCalibrated"] = true;

  if (!sgp.IAQmeasureRaw())
  {
    Serial.println("Raw Measurement failed :(");
    return false;
  }

  doc["SGP30"]["Raw H2"]["value"] = sgp.rawH2;
  doc["SGP30"]["Raw Ethanol"]["value"] = sgp.rawEthanol;

  return true;
}
