# ESP32


The ESP32 is the ESP8266 successor. It adds an extra CPU core, faster Wi-Fi, more GPIOs, and supports Bluetooth 4.2 and Bluetooth low energy

# Current Status

- Sensors
    + [X] wiring & schema
    + [X] read data from sensor
    + [X] data to JSON format
    + [X] adding polymorphisme to sensor classes in order to regroup them into list object and make code clean & dynamic
    + [X] internal error handler if read data fails
- Network
    + [X] config mode by setting ESP32 as an access point 
    + [X] adding local network commandes using UDP broadcast 
    + [X] send data to firebase periodically
- Dual Core ESP32
    + [X] adding mutex (mutual exclusion) 
    + [X] synchronization

    

    

![](MultiCoreComm.png)


![](TimeLineCore0.png)


![](TimeLineCore1.png)



![](Schematic_PFE_Air_Quality_2020-07-16_12-40-15.png)

See also: https://easyeda.com/benabadji.mohammed.salim/pfe-air-quality



### Sensors


| Sensor | Protocol |
| ------ | ------ |
| DHT22 | digital |
| SGP30 | I2C |
| BME680 | I2C |
| MICS6814 | Analog |
| MHZ19 | Serial port |
| MQ131 | Analog |

