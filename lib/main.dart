// import 'dart:developer';

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
        primarySwatch: Colors.pink,
      ),
      home: SpeedometerScaffold(),
      debugShowCheckedModeBanner: false,
    );
  }
}

@immutable
class SpeedometerScaffold extends StatefulWidget {
  bool unitsMetric = false;
  bool showDigital = true;

  @override
  _SpeedometerScaffoldState createState() => _SpeedometerScaffoldState();
}

class _SpeedometerScaffoldState extends State<SpeedometerScaffold> {
  String unitsTitle = 'Units';
  String unitsSubtitle = "Metric / Imperial";
  String showDigitalTitle = "Digital";

  final scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SpeedListenerWidget(
        metric: this.widget.unitsMetric,
        digital: this.widget.showDigital,
      ),
      drawer: Drawer(
        elevation: 16,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
                child: Icon(
              Icons.settings_outlined,
              color: Colors.black,
              size: 24,
            )),
            SwitchListTile(
              value: this.widget.unitsMetric,
              onChanged: (newValue) =>
                  setState(() => this.widget.unitsMetric = newValue),
              title: Text(
                unitsTitle,
              ),
              subtitle: Text(
                unitsSubtitle,
              ),
              tileColor: Color(0xFFF5F5F5),
              activeColor: Color(0xFFF5F5F5),
              activeTrackColor: Colors.grey,
              inactiveTrackColor: Colors.grey,
              dense: false,
              controlAffinity: ListTileControlAffinity.trailing,
            ),
            SwitchListTile(
              value: this.widget.showDigital,
              onChanged: (newValue) =>
                  setState(() => this.widget.showDigital = newValue),
              title: Text(
                showDigitalTitle,
              ),
              tileColor: Color(0xFFF5F5F5),
              activeColor: Color(0xFFF5F5F5),
              activeTrackColor: Colors.grey,
              inactiveTrackColor: Colors.grey,
              dense: false,
              controlAffinity: ListTileControlAffinity.trailing,
            ),
          ],
        ),
      ),
    );
  }
}

@immutable
class SpeedListenerWidget extends StatefulWidget {
  SpeedListenerWidget({Key? key, this.metric = false, this.digital = true})
      : super(key: key);

  final bool metric;
  final bool digital;
  late var speedReader;

  @override
  _SpeedListenerWidgetState createState() => _SpeedListenerWidgetState();
}

class _SpeedListenerWidgetState extends State<SpeedListenerWidget> {
  var _display = '';
  var _speed = 0;
  var _fastestSpeedKPH = 0.0; // kilometers per hour;

  @override
  void initState() {
    super.initState();

    this.widget.speedReader = SpeedReader((final Position position) {
      setState(() {
        var speedKPH = msToKPH(position.speed);
        _speed =
            (this.widget.metric ? speedKPH : kphToMPH(speedKPH)).abs().round();

        // keep track of where we are
        // _lastPosition = position;

        // update the high-score
        if (speedKPH > _fastestSpeedKPH) _fastestSpeedKPH = speedKPH;

        final String displaySpeed = _speed.toString();
        if (this.widget.digital) {
          _display = (this.widget.metric
              ? displaySpeed + 'km/h'
              : displaySpeed + 'MPH');
        } else {
          _display = '';
        }

        print(_display);
      });
    });
  }

  @override
  void dispose() {
    this.widget.speedReader.cancel();
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
