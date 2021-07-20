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

## Action Shot
![IMG_1556](https://user-images.githubusercontent.com/578572/125177886-59076b80-e194-11eb-9aaa-37fbce5c7935.PNG)
