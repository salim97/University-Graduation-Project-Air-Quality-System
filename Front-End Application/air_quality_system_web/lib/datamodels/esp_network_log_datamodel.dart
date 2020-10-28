class ESPNetworkLogDataModel {
  String ip;
  String upTime;
  String msg;
  bool isError;

  ESPNetworkLogDataModel({this.ip, this.upTime, this.msg, this.isError}) ;

  factory ESPNetworkLogDataModel.fromJson(Map<dynamic, dynamic> json) {
    return ESPNetworkLogDataModel()
      ..ip = json['ip'] as String
      ..upTime = json['upTime'] as String
      ..msg = json['msg']as String
      ..isError = json['isError'] as bool;
  }
  static bool isJSONvalide(Map<dynamic, dynamic> json) {
    bool decodeSucceeded = false;
    return json["ip"] != null ? true : false ;
    try {
      var x = ESPNetworkLogDataModel.fromJson(json);
      decodeSucceeded = true;
    } on FormatException catch (e) {
      print('The provided string is not valid JSON');
    }
    print('Decoding succeeded: $decodeSucceeded');
    return decodeSucceeded;
  }
}
