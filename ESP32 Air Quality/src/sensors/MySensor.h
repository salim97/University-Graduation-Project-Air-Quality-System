#ifndef MySensor_H
#define MySensor_H

#define _Sensors_DEBUG false // print messages in serial port

#include <ArduinoJson.h>

class MySensor {
public:
  virtual bool init() = 0;
  virtual bool doMeasure() = 0;
  virtual void toJSON(JsonArray &Sensors) = 0;
};

#endif
