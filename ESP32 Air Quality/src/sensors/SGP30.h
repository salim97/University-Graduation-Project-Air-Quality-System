#ifndef MySGP30_H
#define MySGP30_H
#include "MySensor.h"

#include "Adafruit_SGP30.h"
class MySGP30 : public MySensor {
private:
  Adafruit_SGP30 sgp;
  bool internalError = false;
public:
  MySGP30(){};
  virtual void init() {
    if (!sgp.begin()) {
      Serial.println("Failed to start SGP30 gas sensor - check wiring.");
      while (1)
        ;
    }
    Serial.print("Found SGP30 serial #");
    Serial.print(sgp.serialnumber[0], HEX);
    Serial.print(sgp.serialnumber[1], HEX);
    Serial.println(sgp.serialnumber[2], HEX);

    // If you have a baseline measurement from before you can assign it to
    // start, to 'self-calibrate' sgp.setIAQBaseline(0x8E68, 0x8F41);  // Will
    // vary for each sensor!
  }

  virtual bool doMeasure() {
    if (_Sensors_DEBUG) Serial.println("============= SGP30 =============");
    internalError = false;
    if (!sgp.IAQmeasure()) {
      Serial.println("Measurement failed :(");
      internalError = true;
      return false;
    }

    if (!sgp.IAQmeasureRaw()) {
      Serial.println("Raw Measurement failed :(");
      internalError = true;
      return false;
    }

    return true;
  }

  virtual void toJSON(JsonArray &Sensors) {
    if (internalError) return;
    {
      JsonObject Sensors_0 = Sensors.createNestedObject();
      Sensors_0["sensor"] = "SGP30";
      Sensors_0["name"] = "TVOC";
      Sensors_0["value"] = sgp.TVOC;
      Sensors_0["metric"] = "PPB";
      Sensors_0["isCalibrated"] = true;
    }

    {
      JsonObject Sensors_0 = Sensors.createNestedObject();
      Sensors_0["sensor"] = "SGP30";
      Sensors_0["name"] = "eCO2";
      Sensors_0["value"] = sgp.eCO2;
      Sensors_0["metric"] = "PPM";
      Sensors_0["isCalibrated"] = true;
    }

    {
      JsonObject Sensors_0 = Sensors.createNestedObject();
      Sensors_0["sensor"] = "SGP30";
      Sensors_0["name"] = "Raw H2";
      Sensors_0["value"] = sgp.rawH2;
      Sensors_0["isCalibrated"] = true;
    }
    {
      JsonObject Sensors_0 = Sensors.createNestedObject();
      Sensors_0["sensor"] = "SGP30";
      Sensors_0["name"] = "Raw Ethanol";
      Sensors_0["value"] = sgp.rawEthanol;
      Sensors_0["isCalibrated"] = true;
    }
  }
};


#endif
