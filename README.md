# spdo

A very simple speedometer app written in [Flutter](https://flutter.dev).

## Getting Started

 * Install Flutter: `brew install flutter`
 * Install dependencies: `flutter pub get`
 * Build and run: `flutter run`

## Where things are
 * The Dart code is in [`/lib/`](lib/)
 * Start in [`main.dart`](lib/main.dart)
 * [`speedreader.dart`](lib/speedreader.dart) is the class that wraps the GPS package.
 * [`lib/gauges`](lib/gauges/) are where the different gauge files are located.
 * [`assets/icon.png`](assets/icon.png) is what's used for the app's icon.   
  Updating the icon:
   * Replace `icon.png` in the `/assets` folder with what you're going for.
   * Run the flutter_launcher_icon generator: `flutter pub run flutter_launcher_icons:main`

## Action Shots
![E7lzoBrUUAEMSgj](https://user-images.githubusercontent.com/578572/127730378-ad62ea17-7ad8-48e8-b3fe-2862e96d297e.jpeg)
![Settings](https://user-images.githubusercontent.com/578572/129113477-21d1558a-6c24-4bd3-81b9-37f746f40de8.png)
