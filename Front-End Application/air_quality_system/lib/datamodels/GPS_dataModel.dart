class GPSDataModel {
  double latitude;
  double longitude;
  double altitude;

  fromJson(Map<String, dynamic> json) {
    if (json["GPS"] == null) return;
    latitude = json["GPS"]["latitude"]["value"];
    longitude = json["GPS"]["longitude"]["value"];
    // altitude = json["GPS"]["altitude"]["value"];
  }
}
