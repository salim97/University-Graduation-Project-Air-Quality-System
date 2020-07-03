class GPSDataModel {
  double latitude;
  double longitude;
  double altitude;

  GPSDataModel({this.latitude, this.longitude, this.altitude});

  GPSDataModel.fromJson(Map<String, dynamic> json) {
    if (json["GPS"] == null) return;
    latitude = json["GPS"]["latitude"]["value"];
    longitude = json["GPS"]["longitude"]["value"];
    // altitude = json["GPS"]["altitude"]["value"];
  }

  String toString()
  {
    return latitude.toString()+", "+longitude.toString();
  }
}
