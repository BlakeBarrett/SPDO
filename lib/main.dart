import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'gauges/analog.dart';
import 'gauges/digital.dart';
import 'image_picker_utils.dart';
import 'speedreader.dart';

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
  bool showTopSpeed = false;
  int maxSpeed = 90;

  PackageInfo? packageInfo;
  SharedPreferences? prefs;

  final sliderColor = Color(0xFFF5F5F5);
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final iconSize = 24.0;

  @override
  void initState() {
    super.initState();
    loadPreferences();
    loadPlatformInfo();
  }

  void loadPreferences() async {
    prefs = await SharedPreferences.getInstance();
    unitsMetric = prefs?.getBool('unitsMetric') ?? false;
    showDigital = prefs?.getBool('showDigital') ?? true;
    showAnalog = prefs?.getBool('showAnalog') ?? true;
    maxSpeed = prefs?.getInt('maxSpeed') ?? maxSpeed;
    showTopSpeed = prefs?.getBool('showTopSpeed') ?? false;
  }

  void loadPlatformInfo() {
    PackageInfo.fromPlatform().then((PackageInfo value) {
      setState(() {
        packageInfo = value;
      });
    });
  }

  Widget backgroundChooserWidget() {
    return ListTile(
      title: Row(children: [
        Icon(Icons.add_a_photo),
        Spacer(),
        IconButton(
          icon: Icon(Icons.clear),
          onPressed: () => ImagePickerUtils.clearImage(),
        ),
      ]),
      onTap: () => ImagePickerUtils.browseForImage(),
    );
  }

  Widget unitSelectionWidget() {
    return SwitchListTile(
      value: unitsMetric,
      onChanged: (newValue) => setState(() {
        unitsMetric = newValue;
        prefs?.setBool('unitsMetric', newValue);
      }),
      title: Text(unitsSubtitle, style: TextStyle(fontWeight: FontWeight.bold)),
      tileColor: sliderColor,
      activeColor: sliderColor,
      activeTrackColor: Colors.grey,
      inactiveTrackColor: Colors.grey,
      dense: false,
      controlAffinity: ListTileControlAffinity.trailing,
    );
  }

  Widget digitalSpeedWidget() {
    return SwitchListTile(
      value: showDigital,
      onChanged: (newValue) => setState(() {
        showDigital = newValue;
        prefs?.setBool('showDigital', newValue);
      }),
      secondary: SvgPicture.asset('assets/numeric.svg'),
      tileColor: sliderColor,
      activeColor: sliderColor,
      activeTrackColor: Colors.grey,
      inactiveTrackColor: Colors.grey,
      dense: false,
      controlAffinity: ListTileControlAffinity.trailing,
    );
  }

  Widget analogSpeedWidget() {
    return SwitchListTile(
      value: showAnalog,
      onChanged: (newValue) => setState(() {
        showAnalog = newValue;
        prefs?.setBool('showAnalog', newValue);
      }),
      secondary: SvgPicture.asset('assets/wiper.svg', color: Colors.red),
      tileColor: sliderColor,
      activeColor: sliderColor,
      activeTrackColor: Colors.grey,
      inactiveTrackColor: Colors.grey,
      dense: false,
      controlAffinity: ListTileControlAffinity.trailing,
    );
  }

  Widget maxSpeedEditWidget(Widget actionWidget) {
    return Padding(
        padding: EdgeInsets.only(left: 16.0, right: 24.0),
        child: Row(
          children: [
            SvgPicture.asset('assets/max-speed.svg',
                width: iconSize, height: iconSize, color: Colors.red),
            Spacer(),
            Text(
              "Max Speed",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(
                width: iconSize * 2, height: iconSize * 2, child: actionWidget),
            Text(
              unitsMetric ? "km/h" : "MPH",
              style: TextStyle(fontWeight: FontWeight.bold),
            )
          ],
        ));
  }

  void showEditPopup(BuildContext context) {
    var popup = SimpleDialog(
      children: [
        maxSpeedEditWidget(
          TextField(
            decoration: new InputDecoration(
                labelText: maxSpeed.toString(),
                contentPadding: EdgeInsets.only(left: 12.0, right: 12.0)),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ], // Only numbers can be entered
            onChanged: (newValue) => setState(() {
              maxSpeed = int.parse(newValue);
              prefs?.setInt("maxSpeed", maxSpeed.toInt());
            }),
          ),
        )
      ],
    );
    showDialog(context: context, builder: (context) => popup);
  }

  Widget maxSpeedWidget() {
    if (showAnalog) {
      return maxSpeedEditWidget(TextButton(
        autofocus: true,
        child: Text(maxSpeed.toString()),
        onPressed: () => showEditPopup(context),
      ));
    } else {
      return Row(children: [
        Padding(
          padding: EdgeInsets.all(iconSize.toDouble()),
        )
      ]);
    }
  }

  Widget topSpeedWidget() {
    return SwitchListTile(
      value: showTopSpeed,
      onChanged: (newValue) => setState(() {
        showTopSpeed = newValue;
        prefs?.setBool('showTopSpeed', newValue);
      }),
      secondary: SvgPicture.asset(
        'assets/car-cruise-control.svg',
        color: Colors.green,
      ),
      tileColor: sliderColor,
      activeColor: sliderColor,
      activeTrackColor: Colors.grey,
      inactiveTrackColor: Colors.grey,
      dense: false,
      controlAffinity: ListTileControlAffinity.trailing,
    );
  }

  Widget aboutWidget() {
    return AboutListTile(
      applicationIcon: SvgPicture.asset(
        'assets/icon.svg',
        width: iconSize * 2,
        height: iconSize * 2,
      ),
      applicationName: "SPDO",
      applicationVersion:
          "${packageInfo?.version} build:${packageInfo?.buildNumber}",
      aboutBoxChildren: [
        Center(
          child: Text("It's a speedometer."),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Wait until we've actually finished loading everything we need.
    if (packageInfo == null || prefs == null) {
      return Column();
    }

    return Scaffold(
      backgroundColor: sliderColor,
      resizeToAvoidBottomInset: false,
      body: SpeedListenerWidget(
        metric: unitsMetric,
        digital: showDigital,
        analog: showAnalog,
        maxSpeed: maxSpeed,
        showTopSpeed: showTopSpeed,
      ),
      drawer: Drawer(
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            backgroundChooserWidget(),
            unitSelectionWidget(),
            digitalSpeedWidget(),
            analogSpeedWidget(),
            maxSpeedWidget(),
            topSpeedWidget(),
            aboutWidget(),
          ],
        ),
      ),
    );
  }
}

@immutable
class SpeedListenerWidget extends StatefulWidget {
  SpeedListenerWidget(
      {Key? key,
      this.metric = false,
      this.digital = true,
      this.analog = true,
      required this.maxSpeed,
      this.showTopSpeed = false})
      : super(key: key);

  final bool metric;
  final bool digital;
  final bool analog;
  final int maxSpeed;
  final bool showTopSpeed;
  late final SpeedReader speedReader;

  @override
  _SpeedListenerWidgetState createState() => _SpeedListenerWidgetState();
}

class _SpeedListenerWidgetState extends State<SpeedListenerWidget> {
  var _display = '';
  var _speed = 0;

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

        final String displaySpeed = _speed.toString();
        var suffix =
            (widget.metric ? this.displayMetric : this.displayImperial);

        if (this.widget.digital) {
          _display = displaySpeed + suffix;
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
      analog: widget.analog,
      maxSpeed: widget.maxSpeed,
      showTopSpeed: widget.showTopSpeed,
    );
  }
}

@immutable
class SpeedometerWidget extends StatefulWidget {
  SpeedometerWidget(
      {required this.speed,
      required this.display,
      required this.analog,
      required this.maxSpeed,
      this.showTopSpeed = false})
      : super();
  final double speed;
  final String display;
  final bool analog;
  final int maxSpeed;
  final bool showTopSpeed;

  @override
  _SpeedometerWidgetState createState() => _SpeedometerWidgetState();
}

class _SpeedometerWidgetState extends State<SpeedometerWidget>
    with SingleTickerProviderStateMixin {
  late Animation<double>? _animation;
  late AnimationController? _animationController;

  var _speed = 0.0;
  var _topSpeed = 0.0;
  Image? _background;

  @override
  void initState() {
    super.initState();
    _animationController = new AnimationController(
        duration: const Duration(seconds: 1), vsync: this);
    _animation = Tween<double>(begin: 0, end: widget.maxSpeed * 1.1)
        .animate(_animationController!)
          ..addListener(() {
            setState(() {
              _speed = _animation!.value;
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

  Widget settingsDrawerDisclosureIcon() {
    return Positioned(
        bottom: 0.0,
        left: 0.0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: new IconButton(
            icon: Icon(
              Icons.settings,
              color: Colors.black12,
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    // Loading the background has to happen here, instead of in initState,
    // because the context (which is used to query the screen size) is not
    // available until build() is called.
    ImagePickerUtils.getImage(context).then((value) => setState(() {
          _background = value;
        }));

    if (_topSpeed < widget.speed) {
      _topSpeed = widget.speed;
    }
    _speed = (_animation != null) ? _animation!.value : widget.speed;

    return GestureDetector(
      child: Scaffold(
        body: Center(
          child: Stack(children: [
            if (_background != null) ...[Center(child: _background)],
            settingsDrawerDisclosureIcon(),
            if (_topSpeed > 0 && widget.showTopSpeed) ...[
              // The green top-speed indicator is only shown if
              // the top speed is > 0
              AnalogGauge(
                  speed: _topSpeed,
                  maxSpeed: widget.maxSpeed,
                  color: Colors.greenAccent),
            ],
            Center(
              child: DigitalGauge(value: widget.display),
            ),
            if (this.widget.analog) ...[
              AnalogGauge(speed: _speed, maxSpeed: widget.maxSpeed)
            ],
          ]),
        ),
      ),
      onTap: () => setState(() {
        _topSpeed = 0.0;
      }),
    );
  }
}
