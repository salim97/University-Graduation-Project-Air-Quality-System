import 'dart:ffi';
import 'dart:io' show File;
import 'dart:convert' show json;

void main(List<String> arguments) {
  asyncWork();
}

class ModelDataTemperature {
  final String date;
  double dht22_temperature;
  double bme680_temperature;
  double mhz19_temperature;
  ModelDataTemperature({this.date, this.dht22_temperature, this.bme680_temperature, this.mhz19_temperature});
}

class ModelDataHumidity {
  final String date;
  double dht22_humidity;
  double bme680_humidity;
  ModelDataHumidity({this.date, this.dht22_humidity, this.bme680_humidity});
}

class ModelDataCO2 {
  final String date;
  double sgp30_eco2;
  double mhz19_co2;
  double mics6814_co;
  double mics6814_no2;
  double mics6814_nh3;
  double sgp30_tvoc;
  ModelDataCO2({this.date, this.sgp30_eco2, this.mhz19_co2, this.mics6814_co, this.mics6814_no2, this.mics6814_nh3, this.sgp30_tvoc});
}

asyncWork() async {
  // SGP30 TVOC
  // MICS6814 NO2 NH3 CO
  // MHZ19  CO2    ppm

  List<ModelDataTemperature> listoftemperature = new List<ModelDataTemperature>();
  List<ModelDataHumidity> listofhumidity = new List<ModelDataHumidity>();
  List<ModelDataCO2> listofco2 = new List<ModelDataCO2>();

  Map records = json.decode(
      await new File("d:/Archive/GITHUB/University-Graduation-Project-Air-Quality-System/nodejs/database-backup-2020-09-01.json")
          .readAsString());
  int i = 0;
  records.forEach((key, value) {
    i++;
    // if (i > 1000) return;
    Map record = records[key];
    // print(DateTime.fromMillisecondsSinceEpoch(record["timestamp"]).toIso8601String());
    // var date = new ;
    //   final DateFormat formatter = DateFormat('yyyy-MM-dd');
    // final String formatted = formatter.format(now);

    listoftemperature.add(ModelDataTemperature(date: DateTime.fromMillisecondsSinceEpoch(record["timestamp"]).toString().split(".").first));
    listofhumidity.add(ModelDataHumidity(date: DateTime.fromMillisecondsSinceEpoch(record["timestamp"]).toString().split(".").first));
    listofco2.add(ModelDataCO2(date: DateTime.fromMillisecondsSinceEpoch(record["timestamp"]).toString().split(".").first));

    List<dynamic> sensors = record["Sensors"];
    sensors.forEach((sensor) {
      if (sensor["sensor"] == "DHT22" && sensor["name"] == "Temperature")
        listoftemperature.last.dht22_temperature = double.parse(sensor["value"].toString());
      if (sensor["sensor"] == "BME680" && sensor["name"] == "Temperature")
        listoftemperature.last.bme680_temperature = double.parse(sensor["value"].toString());
      if (sensor["sensor"] == "MHZ19" && sensor["name"] == "Temperature")
        listoftemperature.last.mhz19_temperature = double.parse(sensor["value"].toString());

      if (sensor["sensor"] == "DHT22" && sensor["name"] == "Humidity")
        listofhumidity.last.dht22_humidity = double.parse(sensor["value"].toString());
      if (sensor["sensor"] == "BME680" && sensor["name"] == "Humidity")
        listofhumidity.last.bme680_humidity = double.parse(sensor["value"].toString());

      if (sensor["sensor"] == "SGP30" && sensor["name"] == "eCO2") listofco2.last.sgp30_eco2 = double.parse(sensor["value"].toString());
      if (sensor["sensor"] == "MHZ19" && sensor["name"] == "CO2") listofco2.last.mhz19_co2 = double.parse(sensor["value"].toString());

      if (sensor["sensor"] == "SGP30" && sensor["name"] == "TOVC") listofco2.last.sgp30_tvoc = double.parse(sensor["value"].toString());

      if (sensor["sensor"] == "MICS6814" && sensor["name"] == "CO") listofco2.last.mics6814_co = double.parse(sensor["value"].toString());
      if (sensor["sensor"] == "MICS6814" && sensor["name"] == "NH3") listofco2.last.mics6814_nh3 = double.parse(sensor["value"].toString());
      if (sensor["sensor"] == "MICS6814" && sensor["name"] == "NO2") listofco2.last.mics6814_no2 = double.parse(sensor["value"].toString());
    });
  });

  listoftemperature.removeWhere((element) => element.dht22_temperature == null);
  listofhumidity.removeWhere((element) => element.dht22_humidity == null);
  listofco2.removeWhere((element) => element.mhz19_co2 == null);
  
  listofco2.forEach((element){
    if(element.mics6814_nh3 == null) element.mics6814_nh3 = 0 ;
    if(element.mics6814_nh3 == -1) element.mics6814_nh3 = 0 ;
  });

  {
    String textOutPut = "date time, dht22_temperature, bme680_temperature, mhz19_temperature\n";
    listoftemperature.forEach((element) {
      textOutPut += element.date +
          "," +
          element.dht22_temperature.toString() +
          "," +
          element.bme680_temperature.toString() +
          "," +
          element.mhz19_temperature.toString() +
          "\n";
    });
    var fileCopy = await File(
            "d:/Archive/GITHUB/University-Graduation-Project-Air-Quality-System/nodejs/comparision between temperateur of diffirent sensor in the same device.csv")
        .writeAsString(textOutPut);
  }

  {
    String textOutPut = "Date Time, DHT22 Humidity, BME680 Humidity\n";
    listofhumidity.forEach((element) {
      textOutPut += element.date + "," + element.dht22_humidity.toString() + "," + element.bme680_humidity.toString() + "\n";
    });
    var fileCopy = await File(
            "d:/Archive/GITHUB/University-Graduation-Project-Air-Quality-System/nodejs/comparision between humidity of diffirent sensor in the same device.csv")
        .writeAsString(textOutPut);
  }

  {
    String textOutPut = "Date Time, SGP30 eCO2, MHZ19 CO2, MICS6814 CO, MICS6814 NO2, MICS6814 NH3\n";
    listofco2.forEach((element) {
      textOutPut += element.date +
          "," +
          element.sgp30_eco2.toString() +
          "," +
          element.mhz19_co2.toString() +
          "," +
          element.mics6814_co.toString() +
          "," +
          element.mics6814_no2.toString() +
          "," +
          element.mics6814_nh3.toString() +
          "\n";
    });
    var fileCopy = await File(
            "d:/Archive/GITHUB/University-Graduation-Project-Air-Quality-System/nodejs/comparision between co2 of diffirent sensor in the same device.csv")
        .writeAsString(textOutPut);
  }



}
