import 'package:air_quality_system/ui/screens/contribute/map_picker_view.dart';
import 'package:air_quality_system/ui/screens/contribute/phone_auth_view.dart';
import 'package:flutter/material.dart';

import 'device_sync_view.dart';

class ContributeView extends StatefulWidget {
  ContributeView({Key key}) : super(key: key);

  @override
  _ContributeViewState createState() => _ContributeViewState();
}

class _ContributeViewState extends State<ContributeView> {
  int _currentstep = 0;

  void _movetonext() {
    setState(() {
      _currentstep++;
    });
  }

  void _movetostart() {
    setState(() {
      _currentstep = 0;
    });
  }

  void _showcontent(int s) {
    showDialog<Null>(
      context: context,

      barrierDismissible: false, // user must tap button!

      builder: (BuildContext context) {
        return new AlertDialog(
          title: new Text('You clicked on'),
          content: new SingleChildScrollView(
            child: new ListBody(
              children: <Widget>[
                spr[s].title,
                spr[s].subtitle,
              ],
            ),
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
   
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Contribute"),),
        body: new Stepper(
      steps: [
        // const Step( title:  ,'SubTitle1', 'This is Content', state: StepState.indexed, true)

        Step(
            title: const Text('Sign UP'),
            content: PhoneAuthView(),
            state: _currentstep == 0 ? StepState.editing : StepState.complete,
            isActive: true),

        Step(
            title: const Text('WiFi'),
            content:  MapPickerView(),
            state: _currentstep == 1 ? StepState.editing : StepState.complete,
            isActive: true),

        Step(
            title: const Text('Server'),
            content: const Text('This is Content2'),
            state: _currentstep == 2 ? StepState.editing : StepState.complete,
            isActive: true),
      ],
      type: StepperType.horizontal,
      currentStep: _currentstep,
      controlsBuilder: (BuildContext context, {VoidCallback onStepContinue, VoidCallback onStepCancel}) {
        return _buildVerticalControls(onStepContinue: onStepContinue, onStepCancel: onStepCancel);
      },
    ));
  }

  Widget _buildVerticalControls({VoidCallback onStepContinue, VoidCallback onStepCancel}) {
    Color cancelColor;

    switch (Theme.of(context).brightness) {
      case Brightness.light:
        cancelColor = Colors.black54;
        break;
      case Brightness.dark:
        cancelColor = Colors.white70;
        break;
    }

    final ThemeData themeData = Theme.of(context);
    final MaterialLocalizations localizations = MaterialLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.only(top: 16.0),
      child: null);
  }

  List<Step> spr = <Step>[
    // const Step( title:  ,'SubTitle1', 'This is Content', state: StepState.indexed, true)

    Step(
        title: const Text('Sign UP'),
        content: Expanded(child: Container(child: Text('This is Content1'))),
        state: StepState.editing,
        isActive: true),

    Step(title: const Text('WiFi'), content: const Text('This is Content2'), state: StepState.complete, isActive: true),

    Step(title: const Text('Server'), content: const Text('This is Content2'), state: StepState.indexed, isActive: true),
  ];
}
