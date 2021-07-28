import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'image_picker_utils.dart';
import 'speedreader.dart';
import 'gauges/digital.dart';
import 'gauges/analog.dart';

void main() {
  runApp(SPDO_App());
}

// ignore: camel_case_types
class SPDO_App extends StatelessWidget {
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
  @override
  _SpeedometerScaffoldState createState() => _SpeedometerScaffoldState();
}

class _SpeedometerScaffoldState extends State<SpeedometerScaffold> {
  final String displayMetric = "km/h";
  final String displayImperial = "MPH";
  String unitsSubtitle = "MPH | km/h";

  bool unitsMetric = false;
  bool showDigital = true;
  bool showAnalog = true;

  PackageInfo? packageInfo;

  final sliderColor = Color(0xFFF5F5F5);
  final scaffoldKey = GlobalKey<ScaffoldState>();

  late final SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    loadPreferences();
  }

  void loadPreferences() async {
    prefs = await SharedPreferences.getInstance();
    unitsMetric = prefs.getBool('unitsMetric') ?? false;
    showDigital = prefs.getBool('showDigital') ?? true;
    showAnalog = prefs.getBool('showAnalog') ?? true;
  }

  @override
  Widget build(BuildContext context) {
    PackageInfo.fromPlatform().then((PackageInfo value) {
      setState(() {
        packageInfo = value;
      });
    });

    return Scaffold(
      body: SpeedListenerWidget(
        metric: unitsMetric,
        digital: showDigital,
        analog: showAnalog,
      ),
      drawer: Drawer(
        elevation: 16,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            ListTile(
                title: Icon(
              Icons.settings_outlined,
              color: Colors.black,
              size: 24,
            )),
            SwitchListTile(
              value: showAnalog,
              onChanged: (newValue) => setState(() {
                showAnalog = newValue;
                prefs.setBool('showAnalog', newValue);
              }),
              secondary: SvgPicture.asset('assets/wiper.svg'),
              tileColor: sliderColor,
              activeColor: sliderColor,
              activeTrackColor: Colors.grey,
              inactiveTrackColor: Colors.grey,
              dense: false,
              controlAffinity: ListTileControlAffinity.trailing,
            ),
            SwitchListTile(
              value: showDigital,
              onChanged: (newValue) => setState(() {
                showDigital = newValue;
                prefs.setBool('showDigital', newValue);
              }),
              secondary: SvgPicture.asset('assets/numeric.svg'),
              tileColor: sliderColor,
              activeColor: sliderColor,
              activeTrackColor: Colors.grey,
              inactiveTrackColor: Colors.grey,
              dense: false,
              controlAffinity: ListTileControlAffinity.trailing,
            ),
            SwitchListTile(
              value: unitsMetric,
              onChanged: (newValue) => setState(() {
                unitsMetric = newValue;
                prefs.setBool('unitsMetric', newValue);
              }),
              title: Text(unitsSubtitle,
                  style: TextStyle(fontWeight: FontWeight.bold)),
              tileColor: sliderColor,
              activeColor: sliderColor,
              activeTrackColor: Colors.grey,
              inactiveTrackColor: Colors.grey,
              dense: false,
              controlAffinity: ListTileControlAffinity.trailing,
            ),
            ListTile(
              title: Row(children: [
                Icon(Icons.add_a_photo),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () => ImagePickerUtils.clearImage(),
                ),
              ]),
              onTap: () => ImagePickerUtils.browseForImage(),
            ),
            Spacer(),
            AboutListTile(
              applicationIcon: SvgPicture.asset(
                'assets/icon.svg',
                width: 48,
                height: 48,
              ),
              applicationName: packageInfo?.appName,
              applicationVersion:
                  "${packageInfo?.version} build:${packageInfo?.buildNumber}",
            ),
          ],
        ),
      ),
    );
  }
}

@immutable
class SpeedListenerWidget extends StatefulWidget {
  SpeedListenerWidget(
      {Key? key, this.metric = false, this.digital = true, this.analog = true})
      : super(key: key);

  final bool metric;
  final bool digital;
  final bool analog;
  late final SpeedReader speedReader;

  @override
  _SpeedListenerWidgetState createState() => _SpeedListenerWidgetState();
}

class _SpeedListenerWidgetState extends State<SpeedListenerWidget> {
  var _display = '';
  var _speed = 0;
  var _fastestSpeedKPH = 0.0; // kilometers per hour;

  final displayMetric = "km/h";
  final displayImperial = "MPH";

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
              ? displaySpeed + displayMetric
              : displaySpeed + displayImperial);
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
    return SpeedometerWidget(
        speed: _speed.toDouble(),
        display: _display,
        analog: this.widget.analog);
  }
}

@immutable
class SpeedometerWidget extends StatefulWidget {
  SpeedometerWidget(
      {required this.speed, required this.display, required this.analog})
      : super();
  final double speed;
  final String display;
  final bool analog;

  @override
  _SpeedometerWidgetState createState() => _SpeedometerWidgetState();
}

class _SpeedometerWidgetState extends State<SpeedometerWidget>
    with SingleTickerProviderStateMixin {
  late Animation<double>? _animation;
  late AnimationController? _animationController;

  late var speed = widget.speed;
  Image? _background;

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
    // Loading the background has to happen here, instead of in initState,
    // because the context (which is used to query the screen size) is not
    // available until build() is called.
    ImagePickerUtils.getImage(context).then((value) => setState(() {
          _background = value;
        }));

    double _speed = widget.speed;
    if (_animation != null) {
      _speed = _animation!.value;
    }

    List<Widget> _children = [];
    if (_background != null) {
      _children.add(Center(child: _background));
    }
    _children.add(Center(
      child: DigitalGauge(value: widget.display),
    ));
    if (this.widget.analog) {
      _children.add(AnalogGauge(speed: _speed));
    }

    return Scaffold(
      body: Center(
        child: Stack(children: _children),
      ),
    );
  }
}
