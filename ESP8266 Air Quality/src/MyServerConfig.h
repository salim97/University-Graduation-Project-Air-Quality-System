#ifndef MyDHT22_H
#define MyDHT22_H

#include <LittleFS.h>

class MyServerConfig {
private:
  String serverConfigFileName = "/serverConfig.txt";

public:
  MyServerConfig() {}
  bool begin() {

    Serial.print(F("Inizializing FS... "));
    if (LittleFS.begin()) {
      Serial.println(F("done."));
      return true;
    } else {
      Serial.println(F("fail."));
      return false;
    }
  }

  bool setServerConfig(String config) {
    File file = LittleFS.open(serverConfigFileName, "w");

    if (!file) {
      Serial.println("Error opening file for writing");
      return false;
    }
    Serial.println("File Content:");
    Serial.println(config);
    int bytesWritten = file.print(config);

    if (bytesWritten == 0) {
      Serial.println("File write failed");
      return false;
    }

    file.close();
    return true;
  }

  String getServerConfig() {
    File file = LittleFS.open(serverConfigFileName, "r");

    if (!file) {
      Serial.println("Failed to open file for reading");
      return String("");
    }

    Serial.println("File Content:");
    String tmp = file.readString();

    Serial.println(tmp);

    file.close();
    return tmp;
  }

  void clearServerConfig() {
    bool ok = LittleFS.remove(serverConfigFileName);
    if (ok)
      Serial.println("File was removed");
    else
      Serial.println("Unable to remove file");
  }
};

#endif