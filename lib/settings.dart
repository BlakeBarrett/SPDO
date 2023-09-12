import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

enum SettingsState { NULL, INITIALIZED }

class Settings {
  static const DEFAULT_MAX_SPEED = 35;
  Settings({
    this.metric = false,
    this.digital = true,
    this.analog = true,
    this.maxSpeed = DEFAULT_MAX_SPEED,
    this.showTopSpeed = false,
  });
  bool metric;
  bool digital;
  bool analog;
  int maxSpeed;
  bool showTopSpeed;

  static Settings? _instance;
  static SharedPreferences? _preferences;

  static Future<void> _initFromPreferences() async {
    if (_instance == null) {
      _preferences ??= await SharedPreferences.getInstance();
      _instance = Settings(
        metric: _preferences?.getBool('unitsMetric') ?? false,
        digital: _preferences?.getBool('showDigital') ?? true,
        analog: _preferences?.getBool('showAnalog') ?? true,
        maxSpeed: _preferences?.getInt('maxSpeed') ?? DEFAULT_MAX_SPEED,
        showTopSpeed: _preferences?.getBool('showTopSpeed') ?? false,
      );
    }
  }

  static Future<Settings> getInstance() async {
    if (_instance == null) {
      await Settings._initFromPreferences();
    }
    return _instance!;
  }

  void writePreferences() {
    getInstance().then((instance) {
      _preferences?.setBool('unitsMetric', instance.metric);
      _preferences?.setBool('showDigital', instance.digital);
      _preferences?.setBool('showAnalog', instance.analog);
      _preferences?.setInt('maxSpeed', instance.maxSpeed);
      _preferences?.setBool('showTopSpeed', instance.showTopSpeed);
    });
  }
}
