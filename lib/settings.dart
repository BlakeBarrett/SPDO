import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  static const _DEFAULT_MAX_SPEED = 35;
  Settings({
    this.metric = false,
    this.digital = true,
    this.analog = true,
    this.maxSpeed = _DEFAULT_MAX_SPEED,
    this.showTopSpeed = false,
  });
  bool metric;
  bool digital;
  bool analog;
  int maxSpeed;
  bool showTopSpeed;

  static Settings? _instance;
  static Future<void> _loadPreferences() async {
    if (_instance == null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _instance = Settings(
        metric: prefs.getBool('unitsMetric') ?? false,
        digital: prefs.getBool('showDigital') ?? true,
        analog: prefs.getBool('showAnalog') ?? true,
        maxSpeed: prefs.getInt('maxSpeed') ?? _DEFAULT_MAX_SPEED,
        showTopSpeed: prefs.getBool('showTopSpeed') ?? false,
      );
    }
  }

  static Future<Settings> getInstance() async {
    await Settings._loadPreferences();
    if (_instance != null) {
      return _instance!;
    }
    throw new Exception('Settings not initialized');
  }

  static void writePreferences() async {
    var instance = await getInstance();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('unitsMetric', instance.metric);
    prefs.setBool('showDigital', instance.digital);
    prefs.setBool('showAnalog', instance.analog);
    prefs.setInt('maxSpeed', instance.maxSpeed);
    prefs.setBool('showTopSpeed', instance.showTopSpeed);
  }
}
