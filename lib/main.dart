import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'drawer_widget.dart';
import 'gauges/analog.dart';
import 'gauges/digital.dart';
import 'image_picker_utils.dart';
import 'settings.dart';
import 'speedreader.dart';

const APP_NAME = 'SPDO';

class GaugeSettings {
  final String display;
  final double speed;
  final double topSpeed;
  final int maxSpeed;
  final bool showTopSpeed;
  final bool showAnalog;
  final Widget? background;

  GaugeSettings({
    required this.display,
    required this.speed,
    required this.topSpeed,
    required this.maxSpeed,
    required this.showTopSpeed,
    required this.showAnalog,
    this.background,
  });
}

Future<void> main() async {
  runApp(const SPDO_App());
}

// ignore: camel_case_types
class SPDO_App extends StatelessWidget {
  const SPDO_App({super.key});

  @override
  Widget build(final BuildContext context) {
    return MaterialApp(
      title: APP_NAME,
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: const SpeedoScaffold(),
      debugShowCheckedModeBanner: false,
    );
  }
}

@immutable
class SpeedoScaffold extends StatelessWidget {
  const SpeedoScaffold({super.key});

  @override
  Widget build(final BuildContext context) {
    return const Scaffold(
      drawer: DrawerWidget(),
      body: SpeedListenerWidget(),
    );
  }
}

@immutable
class SpeedListenerWidget extends StatefulWidget {
  const SpeedListenerWidget({super.key});

  double msToKPH(final double metersPerSecond) {
    const secondsPerHour = 60 * 60;
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

  late final SpeedReader speedReader;

  int get maxSpeed => settings?.maxSpeed ?? Settings.DEFAULT_MAX_SPEED;
  bool get metric => settings?.metric ?? false;
  bool get showTopSpeed => settings?.showTopSpeed ?? false;
  bool get analog => settings?.analog ?? true;
  bool get digital => settings?.digital ?? true;

  var _display = '';
  var _speed = 0.0;
  var _topSpeed = 0.0;
  late Image? _background;

  late Animation<double>? _animation;
  late AnimationController? _animationController;

  @override
  void dispose() {
    settings?.writePreferences();
    speedReader.cancel();
    _animationController?.dispose();
    super.dispose();
  }

  void initAnimationController() {
    _animationController =
        AnimationController(duration: const Duration(seconds: 1), vsync: this);
    _animation = Tween<double>(begin: 0, end: maxSpeed * 1.1)
        .animate(_animationController!)
      ..addListener(() {
        setState(() {
          _speed = _animation?.value ?? 0.0;
        });
      });
    _animationController?.addStatusListener((final status) {
      switch (status) {
        case AnimationStatus.completed:
          _animationController?.reverse();
          break;
        case AnimationStatus.dismissed:
          _animationController?.dispose();
          _animationController = null;
          _animation = null;
          break;
        default:
          break;
      }
    });
    _animationController?.forward();
  }

  void initSpeedReader() {
    speedReader = SpeedReader((final Position position) {
      setState(() {
        if (position.speedAccuracy < 0 || position.speed.isNaN) {
          return;
        }

        final speedKPH = widget.msToKPH(position.speed);

        _speed = (metric ? speedKPH : widget.kphToMPH(speedKPH));

        if (_topSpeed < _speed) {
          _topSpeed = _speed;
        }

        if (digital) {
          _display = widget.displaySpeed(_speed, metric);
        } else {
          _display = '';
        }

        if (kDebugMode) {
          print(_display);
        }
      });
    });
  }

  @override
  Widget build(final BuildContext context) {
    // Loading the background has to happen here, instead of in initState,
    // because the context (which is used to query the screen size) is not
    // available until build() is called.
    ImagePickerUtils.getImage(context).then((final value) => setState(() {
          _background = value;
        }));

    // For some reason, trying to initialize properties async in initState()
    // causes an error to be thrown when _touching_ any instance of a nullable
    // property. This is a stupid race condition and a gross workaround due to
    // SharedPreferences.getInstance() being async.
    if (settings == null) {
      Settings.getInstance().then((final value) {
        setState(() {
          settings = value;
          initAnimationController();
          initSpeedReader();
        });
      });

      return Center(
        child: _background != null
            ? Image(image: _background!.image)
            : Text(
                APP_NAME,
                style: Theme.of(context).textTheme.displayLarge,
              ),
      );
    }

    // if we're not animating, use actual speed values
    if (_animation != null) {
      _speed = _animation?.value ?? 0.0;
    }

    return GestureDetector(
        child: GaugeWidget(
          GaugeSettings(
              display: _display,
              speed: _speed,
              showAnalog: analog,
              showTopSpeed: showTopSpeed,
              topSpeed: _topSpeed,
              maxSpeed: maxSpeed,
              background: _background),
        ),
        onTap: () => setState(() {
              _topSpeed = 0.0;
            }));
  }
}

class GaugeWidget extends StatelessWidget {
  final String display;
  final double speed;
  final double topSpeed;
  final int maxSpeed;
  final bool showTopSpeed;
  final bool showAnalog;
  final Widget? background;

  GaugeWidget(final GaugeSettings settings, {super.key})
      : display = settings.display,
        speed = settings.speed,
        topSpeed = settings.topSpeed,
        maxSpeed = settings.maxSpeed,
        showTopSpeed = settings.showTopSpeed,
        showAnalog = settings.showAnalog,
        background = settings.background;

  @override
  Widget build(final BuildContext context) {
    return Center(
      child: Stack(alignment: Alignment.topLeft, children: [
        if (background != null) ...[Center(child: background)],
        settingsDrawerDisclosureIconButtonWidget(context),
        if (topSpeed > 0 && showTopSpeed) ...[
          // The green top-speed indicator is only shown if
          // the top speed is > 0
          AnalogGauge(
              speed: topSpeed, maxSpeed: maxSpeed, color: Colors.greenAccent),
        ],
        Center(
          child: DigitalGauge(value: display),
        ),
        if (showAnalog) ...[AnalogGauge(speed: speed, maxSpeed: maxSpeed)],
      ]),
    );
  }
}
