class LocalNetworkDevice {
  String ip;
  String upTime;
  String name;
  LocalNetworkDevice({this.ip, this.upTime, this.name});
    factory LocalNetworkDevice.fromJson(Map<dynamic, dynamic> json) {
    return LocalNetworkDevice()
      ..ip = json['ip'] as String
      ..upTime = json['upTime'] as String
      ..name = json['deviceName']as String;
  }
  static bool isJSONvalide(Map<dynamic, dynamic> json) {
        return json["isError"] == null ? true : false  ;
  }
}