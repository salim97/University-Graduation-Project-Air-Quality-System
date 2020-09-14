import 'dart:async';

import 'package:air_quality_system/app/locator.dart';
import 'package:esptouch_flutter/esptouch_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:wifi_info_plugin/wifi_info_plugin.dart';

class ESPTouchView extends StatefulWidget {
  @override
  _ESPTouchViewState createState() => _ESPTouchViewState();
}

const helperSSID =
    "SSID is the technical term for a network name. When you set up a wireless home network, you give it a name to distinguish it from other networks in your neighbourhood.";
const helperBSSID = "BSSID is the MAC address of the wireless access point (router).";
const helperPassword = "The password of the Wi-Fi network";

class _ESPTouchViewState extends State<ESPTouchView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _ssid = TextEditingController();
  final TextEditingController _bssid = TextEditingController();
  final TextEditingController _password = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchWifiInfo();
  }

  WifiInfoWrapper _wifiObject;
  final DialogService _dialogService = locator<DialogService>();
  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    WifiInfoWrapper wifiObject;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      wifiObject = await WifiInfoPlugin.wifiDetails;
    } on PlatformException {
      await _dialogService.showDialog(
        title: "Turn Your WiFi ON",
        description: "Couldn't get your wifi SSID and MAC Address, turn wifi on and connect to your wifi",
        dialogPlatform: DialogPlatform.Material,
      );
    }
    if (!mounted) return;

    setState(() {
      _wifiObject = wifiObject;
    });
  }

  void fetchWifiInfo() async {
    await initPlatformState();
    setState(() {
      fetchingWifiInfo = true;
    });
    try {
      _ssid.text = _wifiObject?.ssid;
      _bssid.text = _wifiObject?.bssId;
      _password.text = "qt2019cpp";
      if (_ssid.text != null && _ssid.text.isNotEmpty) {
        _ssid.text = _ssid.text.replaceAll("\"", "");
      }
    } finally {
      setState(() {
        fetchingWifiInfo = false;
      });
    }
  }

  @override
  void dispose() {
    _ssid.dispose();
    _bssid.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ESP-TOUCH',
          style: TextStyle(
            fontFamily: 'serif-monospace',
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      // Using builder to get context without creating new widgets
      //  https://docs.flutter.io/flutter/material/Scaffold/of.html
      body: Builder(builder: (BuildContext context) {
        return Center(
          child: form(context),
        );
      }),
    );
  }

  bool fetchingWifiInfo = false;

  createTask() {
    final taskParameter = ESPTouchTaskParameter();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskRoute(
            task: ESPTouchTask(
          ssid: _ssid.text,
          bssid: _bssid.text,
          password: _password.text,
          // packet: ESPTouchPacket.multicast,
          packet: ESPTouchPacket.broadcast,
          taskParameter: taskParameter,
        )),
      ),
    );
  }

  Widget form(BuildContext context) {
    Color color = Theme.of(context).primaryColor;
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: <Widget>[
          Center(
            child: OutlineButton(
              highlightColor: Colors.transparent,
              highlightedBorderColor: color,
              onPressed: fetchingWifiInfo ? null : fetchWifiInfo,
              child: fetchingWifiInfo
                  ? Text(
                      'Fetching WiFi info',
                      style: TextStyle(color: Colors.grey),
                    )
                  : Text(
                      'Use current Wi-Fi',
                      style: TextStyle(color: color),
                    ),
            ),
          ),
          TextFormField(
            controller: _ssid,
            decoration: const InputDecoration(
              labelText: 'SSID',
              hintText: 'Tony\'s iPhone',
              helperText: helperSSID,
            ),
          ),
          TextFormField(
            controller: _bssid,
            decoration: const InputDecoration(
              labelText: 'BSSID',
              hintText: '00:a0:c9:14:c8:29',
              helperText: helperBSSID,
            ),
          ),
          TextFormField(
            controller: _password,
            decoration: const InputDecoration(
              labelText: 'Password',
              hintText: r'V3Ry.S4F3-P@$$w0rD',
              helperText: helperPassword,
            ),
          ),
          Center(
            child: RaisedButton(
              onPressed: () {
                createTask();
              },
              child: const Text('Execute'),
            ),
          ),
        ],
      ),
    );
  }
}

class TaskRoute extends StatefulWidget {
  final ESPTouchTask task;

  TaskRoute({this.task});

  @override
  State<StatefulWidget> createState() {
    return TaskRouteState();
  }
}

class TaskRouteState extends State<TaskRoute> {
  Stream<ESPTouchResult> _stream;
  StreamSubscription<ESPTouchResult> _streamSubscription;
  Timer _timer;

  final List<ESPTouchResult> _results = [];

  @override
  void initState() {
    _stream = widget.task.execute();
    _streamSubscription = _stream.listen(_results.add);
    final receiving = widget.task.taskParameter.waitUdpReceiving;
    final sending = widget.task.taskParameter.waitUdpSending;
    final cancelLatestAfter = receiving + sending;
    _timer = Timer(cancelLatestAfter, () {
      _streamSubscription?.cancel();
      if (_results.isEmpty && mounted) {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('No devices found'),
                actions: <Widget>[
                  FlatButton(
                    onPressed: () {
                      Navigator.of(context)..pop()..pop();
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            });
      }
    });
    super.initState();
  }

  @override
  dispose() {
    _timer.cancel();
    _streamSubscription?.cancel();
    super.dispose();
  }

  Widget waitingState(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Theme.of(context).primaryColor),
          ),
          SizedBox(height: 16),
          Text('Waiting for results'),
        ],
      ),
    );
  }

  Widget error(BuildContext context, String s) {
    return Center(child: Text(s, style: TextStyle(color: Colors.red)));
  }

  copyValue(BuildContext context, String label, String v) {
    return () {
      Clipboard.setData(ClipboardData(text: v));
      Scaffold.of(context).showSnackBar(SnackBar(content: Text('Copied $label to clipboard: $v')));
    };
  }

  Widget noneState(BuildContext context) {
    return Text('None');
  }

  Widget resultList(BuildContext context) {
    return ListView.builder(
      itemCount: _results.length,
      itemBuilder: (_, index) {
        final result = _results[index];
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              GestureDetector(
                onLongPress: copyValue(context, 'BSSID', result.bssid),
                child: Row(
                  children: <Widget>[
                    Text('BSSID: ', style: Theme.of(context).textTheme.body2),
                    Text(result.bssid, style: TextStyle(fontFamily: 'monospace')),
                  ],
                ),
              ),
              GestureDetector(
                onLongPress: copyValue(context, 'IP', result.ip),
                child: Row(
                  children: <Widget>[
                    Text('IP: ', style: Theme.of(context).textTheme.body2),
                    Text(result.ip, style: TextStyle(fontFamily: 'monospace')),
                  ],
                ),
              ),
              RaisedButton(
                child: Text("Check if everything is ok "),
                onPressed: () {},
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task'),
      ),
      body: Container(
        child: StreamBuilder<ESPTouchResult>(
          builder: (context, AsyncSnapshot<ESPTouchResult> snapshot) {
            if (snapshot.hasError) {
              return error(context, 'Error in StreamBuilder');
            }
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Theme.of(context).primaryColor),
                ),
              );
            }
            switch (snapshot.connectionState) {
              case ConnectionState.active:
                return resultList(context);
              case ConnectionState.none:
                return noneState(context);
              case ConnectionState.done:
                return resultList(context);
              case ConnectionState.waiting:
                return waitingState(context);
            }
            return error(context, 'Unexpected');
          },
          stream: _stream,
        ),
      ),
    );
  }
}
