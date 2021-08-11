import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'drawer_widget.dart';
import 'gauges/analog.dart';
import 'gauges/digital.dart';
import 'image_picker_utils.dart';
import 'settings.dart';
import 'speedreader.dart';

const APP_NAME = 'SPDO';

Future<void> main() async {
  runApp(SPDO_App());
}

// ignore: camel_case_types
class SPDO_App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: APP_NAME,
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: SpeedoScaffold(),
      debugShowCheckedModeBanner: false,
    );
  }
}

@immutable
class SpeedoScaffold extends StatefulWidget {
  @override
  _SpeedoScaffoldState createState() => _SpeedoScaffoldState();
}

class _SpeedoScaffoldState extends State<SpeedoScaffold> {
  @override
  Widget build(final BuildContext context) {
    var body = SpeedListenerWidget();
    var drawerWidget = DrawerWidget();
    var scaffold = Scaffold(
      drawer: drawerWidget,
      body: body,
    );
    return scaffold;
  }
}

@immutable
class SpeedListenerWidget extends StatefulWidget {
  late final SpeedReader speedReader;

  double msToKPH(final double metersPerSecond) {
    final double secondsPerHour = 60 * 60;
    final double metersPerHour = metersPerSecond * secondsPerHour;
    return metersPerHour / 1000;
  }

  double kphToMPH(final double kmph) {
    return (kmph / 1.609);
  }

  String displaySpeed(final double speed, final bool metric) {
    return speed.round().toString() + (metric ? "km/h" : "MPH");
  }

  @override
  _SpeedListenerWidgetState createState() => _SpeedListenerWidgetState();
}

class _SpeedListenerWidgetState extends State<SpeedListenerWidget>
    with SingleTickerProviderStateMixin {
  Settings? settings;

  int get maxSpeed => settings?.maxSpeed ?? Settings.DEFAULT_MAX_SPEED;
  bool get metric => settings?.metric ?? false;
  bool get showTopSpeed => settings?.showTopSpeed ?? false;
  bool get analog => settings?.analog ?? true;
  bool get digital => settings?.digital ?? true;

  var _display = '';
  var _speed = 0.0;
  var _topSpeed = 0.0;
  Image? _background;

  late Animation<double>? _animation;
  late AnimationController? _animationController;

  @override
  void dispose() {
    settings?.writePreferences();
    this.widget.speedReader.cancel();
    _animationController?.dispose();
    super.dispose();
  }

  Future<void> initSettings() async {
    settings = await Settings.getInstance();
  }

  void initAnimationController() {
    _animationController = new AnimationController(
        duration: const Duration(seconds: 1), vsync: this);
    _animation = Tween<double>(begin: 0, end: maxSpeed * 1.1)
        .animate(_animationController!)
          ..addListener(() {
            setState(() {
              _speed = _animation?.value ?? 0.0;
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

  void initSpeedReader() {
    this.widget.speedReader = SpeedReader((final Position position) {
      setState(() {
        if (position.speedAccuracy < 0) {
          return;
        }

        var speedKPH = widget.msToKPH(position.speed);

        _speed =
            (metric ? speedKPH : widget.kphToMPH(speedKPH)).abs().toDouble();

        if (_topSpeed < _speed) {
          _topSpeed = _speed;
        }

        if (digital) {
          _display = widget.displaySpeed(_speed, metric);
        } else {
          _display = '';
        }

        print(_display);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Loading the background has to happen here, instead of in initState,
    // because the context (which is used to query the screen size) is not
    // available until build() is called.
    ImagePickerUtils.getImage(context).then((value) => setState(() {
          _background = value;
        }));

    // For some reason, trying to initialize properties async in initState()
    // causes an error to be thrown when _touching_ any instance of a nullable
    // property. This is a stupid race condition and a gross workaround due to
    // SharedPreferences.getInstance() being async.
    if (settings == null) {
      Settings.getInstance().then((value) {
        setState(() {
          settings = value;
          initAnimationController();
          initSpeedReader();
        });
      });
      return _background ??
          Center(
            child: Text(
              APP_NAME,
              style: Theme.of(context).textTheme.headline1,
            ),
          );
    }

    // if we're not animating, use actual speed values
    if (_animation != null) {
      _speed = _animation?.value ?? 0.0;
    }

    var body = Center(
      child: Stack(children: [
        if (_background != null) ...[Center(child: _background)],
        settingsDrawerDisclosureIconButtonWidget(context),
        if (_topSpeed > 0 && showTopSpeed) ...[
          // The green top-speed indicator is only shown if
          // the top speed is > 0
          AnalogGauge(
              speed: _topSpeed, maxSpeed: maxSpeed, color: Colors.greenAccent),
        ],
        Center(
          child: DigitalGauge(value: _display),
        ),
        if (analog) ...[AnalogGauge(speed: _speed, maxSpeed: maxSpeed)],
      ]),
    );

    return GestureDetector(
        child: body,
        onTap: () => setState(() {
              _topSpeed = 0.0;
            }));
  }
}
