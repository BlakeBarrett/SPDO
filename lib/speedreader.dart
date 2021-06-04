import 'package:geolocator/geolocator.dart';
import 'dart:async';

class SpeedReader {
  late LocationPermission _permission;
  late var _listener;

  SpeedReader(void updateListener(Position value)) {
    _determinePosition().then((value) {
      _listener = Geolocator.getPositionStream(
        desiredAccuracy: LocationAccuracy.bestForNavigation,
        intervalDuration: Duration(microseconds: 0),
      ).listen(updateListener);
    });
  }

  void cancel() {
    _listener.cancel();
  }

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    _permission = await Geolocator.checkPermission();

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      var error = 'Location services are disabled.';
      print(error);
      return Future.error(error);
    }

    _permission = await Geolocator.checkPermission();
    if (_permission == LocationPermission.denied) {
      _permission = await Geolocator.requestPermission();
      if (_permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        var error = 'Location permissions are denied';
        print(error);
        return Future.error(error);
      }
    }

    if (_permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      var error =
          'Location permissions are permanently denied, we cannot request permissions.';
      print(error);
      return Future.error(error);
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }
}
