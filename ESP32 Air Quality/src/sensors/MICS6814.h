#ifndef MyMICS6814_H
#define MyMICS6814_H
#include "MySensor.h"

#include "../lib/MICS6814.h"
#define PIN_CO 32  // ADC1_CHANNEL_4
#define PIN_NO2 34 // ADC1_CHANNEL_6
#define PIN_NH3 35 // ADC1_CHANNEL_7
MICS6814 mics6814(PIN_CO, PIN_NO2, PIN_NH3);

class MyMICS6814 : public MySensor{
public:
  virtual bool init() {
    Serial.println(F("start calibrating MICS6814 ..."));
    mics6814.calibrate();
    return doMeasure();
  }

  virtual bool doMeasure() {
    if (_Sensors_DEBUG)Serial.println("============= MICS6814 =============");

    return true;
  }

  virtual void toJSON(JsonArray &Sensors) {
    {
      JsonObject Sensors_0 = Sensors.createNestedObject();
      Sensors_0["sensor"] = "MICS6814";
      Sensors_0["name"] = "NO2";
      Sensors_0["value"] = mics6814.measure(NO2);
      Sensors_0["metric"] = "PPM";
      Sensors_0["isCalibrated"] = true;
    }
    {
      JsonObject Sensors_0 = Sensors.createNestedObject();
      Sensors_0["sensor"] = "MICS6814";
      Sensors_0["name"] = "NH3";
      Sensors_0["value"] = mics6814.measure(NH3);
      Sensors_0["metric"] = "PPM";
      Sensors_0["isCalibrated"] = true;
    }
    {
      JsonObject Sensors_0 = Sensors.createNestedObject();
      Sensors_0["sensor"] = "MICS6814";
      Sensors_0["name"] = "CO";
      Sensors_0["value"] = mics6814.measure(CO);
      Sensors_0["metric"] = "PPM";
      Sensors_0["isCalibrated"] = true;
    }
  }
};

#endif