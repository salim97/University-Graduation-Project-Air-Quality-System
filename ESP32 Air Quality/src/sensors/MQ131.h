#ifndef MQ131_H
#define MQ131_H
#include "MySensor.h"
#include <MQUnifiedsensor.h>

/************************Hardware Related
 * Macros************************************/
#define Board                                                                  \
  ("ESP-32")     // Wemos ESP-32 or other board, whatever have ESP32 core.
#define Pin (27) // GPIO27 for your ESP32
/***********************Software Related
 * Macros************************************/
#define Type                                                                   \
  ("MQ-131") // MQ3 or other MQ Sensor, if change this verify your a and b
             // values.
#define Voltage_Resolution                                                     \
  (3.3) // 3V3 <- IMPORTANT. Source:
        // https://randomnerdtutorials.com/esp32-adc-analog-read-arduino-ide/
#define ADC_Bit_Resolution                                                     \
  (12) // ESP-32 bit resolution. Source:
       // https://randomnerdtutorials.com/esp32-adc-analog-read-arduino-ide/
#define RatioMQ131CleanAir                                                     \
  (15) // Ratio of your sensor, for this example an MQ-131

// Declare Sensor
MQUnifiedsensor mq131(Board, Voltage_Resolution, ADC_Bit_Resolution, Pin, Type);

class MQ131 : public MySensor {
private:
  bool internalError = false;

public:
  virtual bool init() {

    // Set math model to calculate the PPM concentration and the value of
    // constants
    mq131.setRegressionMethod(1); //_PPM =  a*ratio^b
    mq131.setA(23.943);
    // Configurate the ecuation values to get O3 concentration
    mq131.setB(-1.11);

    /*
      Exponential regression:
    GAS     | a      | b
    NOx     | -462.43 | -2.204
    CL2     | 47.209 | -1.186
    O3      | 23.943 | -1.11
    */

    /*****************************  MQ Init
     * ********************************************/
    // Remarks: Configure the pin of arduino as input.
    /************************************************************************************/
    mq131.init();
    /*
      //If the RL value is different from 10K please assign your RL value with
      the following method: MQ131.setRL(10);
    */
    /*****************************  MQ CAlibration
     * ********************************************/
    // Explanation:
    // In this routine the sensor will measure the resistance of the sensor
    // supposing before was pre-heated and now is on clean air (Calibration
    // conditions), and it will setup R0 value. We recomend execute this routine
    // only on setup or on the laboratory and save on the eeprom of your arduino
    // This routine not need to execute to every restart, you can load your R0
    // if you know the value Acknowledgements:
    // https://jayconsystems.com/blog/understanding-a-gas-sensor
    Serial.print("Calibrating please wait.");
    float calcR0 = 0;
    for (int i = 1; i <= 10; i++) {
      mq131.update(); // Update data, the arduino will be read the voltage on
                      // the analog pin
      calcR0 += mq131.calibrate(RatioMQ131CleanAir);
      Serial.print(".");
    }
    mq131.setR0(calcR0 / 10);
    Serial.println("  done!.");

    if (isinf(calcR0)) {
      Serial.println("Warning: Conection issue founded, R0 is infite (Open "
                     "circuit detected) please check your wiring and supply");
      internalError = true;
      return false ;
    }
    if (calcR0 == 0) {
      Serial.println(
          "Warning: Conection issue founded, R0 is zero (Analog pin with short "
          "circuit to ground) please check your wiring and supply");
      internalError = true;
      return false;
    }
    /*****************************  MQ CAlibration
     * ********************************************/
    mq131.serialDebug(true);
    return true ;
  }

  virtual bool doMeasure() {
 
    if( internalError == true) return false ;
    mq131.update(); // Update data, the arduino will be read the voltage on the
    // analog pin
    return true;
  }

  virtual void toJSON(JsonArray &Sensors) {
  
if( internalError == true) return  ;
    {
      JsonObject Sensors_0 = Sensors.createNestedObject();
      Sensors_0["sensor"] = "MQ131";
      Sensors_0["name"] = "Ozone";
      // Sensors_0["value"] = mq131.readSensor();
      Sensors_0["value"] = analogRead(Pin);
      Sensors_0["metric"] = "ppm";
      Sensors_0["isCalibrated"] = false;
    }
  }
};

#endif