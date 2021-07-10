import 'package:flutter/animation.dart';
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

@immutable
class SpeedometerWidget extends StatefulWidget {
  SpeedometerWidget({required this.speed, required this.display}) : super();
  final double speed;
  final String display;

  @override
  _SpeedometerWidgetState createState() => _SpeedometerWidgetState();
}

class _SpeedometerWidgetState extends State<SpeedometerWidget>
    with SingleTickerProviderStateMixin {
  late Animation<double>? _animation;
  late AnimationController? _animationController;

  late var speed = widget.speed;

  @override
  void initState() {
    super.initState();
    _animationController = new AnimationController(
        duration: const Duration(seconds: 1), vsync: this);
    _animation =
        Tween<double>(begin: 0, end: 100.0).animate(_animationController!)
          ..addListener(() {
            setState(() {
              speed = _animation!.value;
            });
          });
    _animationController?.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController?.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _animationController?.dispose();
        _animationController = null;
        _animation = null;
      }
    });
    _animationController?.forward();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double _speed = widget.speed;
    if (_animation != null) {
      _speed = _animation!.value;
    }
    return Scaffold(
      body: Center(
        child: Stack(
          children: <Widget>[
            AnalogGauge(speed: _speed),
            Center(
              child: DigitalGauge(value: widget.display),
            )
          ],
        ),
      ),
    );
  }
}
