import 'dart:io';
import 'package:air_quality_system/datamodels/device_dataModel.dart';
import 'package:get_ip/get_ip.dart';
import 'package:stacked/stacked.dart';
import 'dart:convert';

// class HomeViewModel extends FutureViewModel<void> {
class LocalNetworkViewModel extends BaseViewModel {
  DeviceDataModel devices = new DeviceDataModel();
  RawDatagramSocket socket;
  // @override
  void initState() async {
    print("=================== initState ");
    RawDatagramSocket.bind(InternetAddress.anyIPv4, 9876).then((RawDatagramSocket socket) {
      print('Datagram socket ready to receive');
      print('${socket.address.address}:${socket.port}');
      socket.broadcastEnabled = true;
      this.socket = socket;
      notifyListeners();
      socket.listen((RawSocketEvent e) {
        Datagram d = socket.receive();
        if (d == null) return;
        String message = new String.fromCharCodes(d.data).trim();
        message = message.replaceAll("Â", "");
        print('Datagram from ${d.address.address}:${d.port}: ${message}');
        if (!isJSON(message)) return;
        Map<String, dynamic> _json = json.decode(message);

        devices.fromJson(_json);

        notifyListeners();
      });
    });

    notifyListeners();
  }

  @override
  void onError(error) {
    // error thrown above will be sent here
    // We can show a dialog, set the error message to show on the UI
    // the UI will be rebuilt after this is called so you can set properties.
  }

  refresh() async {
    String ipAddress = await GetIp.ipAddress;
    List<String> split = ipAddress.split(".");
    split[3] = "255";
    ipAddress = split[0] + "." + split[1] + "." + split[2] + "." + split[3];
    print(ipAddress);
    // socket.send('<refresh>'.codeUnits, InternetAddress.anyIPv4, 9876);
    socket.send("<refresh>".codeUnits, InternetAddress(ipAddress), 9876);
  }

  bool isJSON(String msg) {
    bool decodeSucceeded = false;
    try {
      var x = json.decode(msg) as Map<String, dynamic>;
      decodeSucceeded = true;
    } on FormatException catch (e) {
      print('The provided string is not valid JSON');
    }
    print('Decoding succeeded: $decodeSucceeded');
    return decodeSucceeded;
  }
}