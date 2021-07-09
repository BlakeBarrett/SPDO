import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'speedreader.dart';
import 'gauges/digital.dart';
import 'gauges/analog.dart';

void main() {
  runApp(SPDO_App());
}

// ignore: camel_case_types
class SPDO_App extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SPDO',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.pink,
      ),
      home: SpeedListenerWidget(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SpeedListenerWidget extends StatefulWidget {
  SpeedListenerWidget({Key? key}) : super(key: key);
  @override
  _SpeedListenerWidgetState createState() => _SpeedListenerWidgetState();
}

class _SpeedListenerWidgetState extends State<SpeedListenerWidget> {
  var _display = '0';
  var _speed = 0;
  var _showMetric = false;
  var _fastestSpeedKPH = 0.0; // kilometers per hour;

  late var _speedReader;

  @override
  void initState() {
    super.initState();
    _speedReader = SpeedReader((final Position position) {
      setState(() {
        var speedKPH = msToKPH(position.speed);
        _speed = (_showMetric ? speedKPH : kphToMPH(speedKPH)).abs().round();

        // keep track of where we are
        // _lastPosition = position;

        // update the high-score
        if (speedKPH > _fastestSpeedKPH) _fastestSpeedKPH = speedKPH;

        final String displaySpeed = _speed.toString();

        _display = (_showMetric ? displaySpeed + 'km/h' : displaySpeed + 'MPH');

        print(_display);
      });
    });
  }

  @override
  void dispose() {
    _speedReader.cancel();
    super.dispose();
  }

  double msToKPH(double metersPerSecond) {
    final double secondsPerHour = 60 * 60;
    final double metersPerHour = metersPerSecond * secondsPerHour;
    return metersPerHour / 1000;
  }

  double kphToMPH(double kmph) {
    return (kmph / 1.609);
  }

  @override
  Widget build(BuildContext context) {
    return SpeedometerWidget(speed: _speed.toDouble(), display: _display);
  }
}

class SpeedometerWidget extends StatelessWidget {
  const SpeedometerWidget({required this.speed, required this.display})
      : super();
  final double speed;
  final String display;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          children: <Widget>[
            AngledNeedle(angle: speed),
            Center(
              child: DigitalGauge(value: display),
            )
          ],
        ),
      ),
    );
  }
}
