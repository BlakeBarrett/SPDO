# SPDO

A very simple speedometer app written in Qt/QML.

## Production Links

* [Google Play](https://play.google.com/store/apps/details?id=com.blakebarrett.spdo) (Flutter version)
* [App Store](https://apps.apple.com/app/id1587277823) (Flutter version)

## Getting Started

* Install Qt: Download and install Qt from [qt.io](https://www.qt.io/download)
* Configure the project:

   ```bash
   mkdir -p build && cd build
   cmake .. -DCMAKE_PREFIX_PATH="/path/to/your/Qt/installation"
   ```

* Build the project:

   ```bash
   cmake --build .
   ```

* Run the application:

   ```bash
   open appSPDO.app    # macOS
   # OR
   ./appSPDO           # Linux
   # OR
   appSPDO.exe         # Windows
   ```

## VS Code Integration

This project includes VS Code tasks for easy building and running:

* Build: Run the "Build Qt Project" task
* Clean Build: Run the "Clean and Build Qt Project" task
* Run: Run the "Run Qt Project" task

## Project Structure

* [`main.cpp`](main.cpp) - Application entry point
* [`Main.qml`](Main.qml) - Main QML interface with speedometer components
* [`assets/`](assets/) - Contains SVG assets for the UI:
  * `numeric.svg` - Digital display icon
  * `wiper.svg` - Analog gauge icon
  * `max-speed.svg` - Maximum speed indicator icon
  * `car-cruise-control.svg` - Top speed indicator icon
  * `icon.svg` and `icon.png` - Application icons

## Features

* Digital speedometer display
* Analog gauge needle
* Top speed indicator
* Metric/Imperial unit selection
* Custom background image support
* Configurable maximum speed

## Action Shots

![E7lzoBrUUAEMSgj](https://user-images.githubusercontent.com/578572/127730378-ad62ea17-7ad8-48e8-b3fe-2862e96d297e.jpeg)
![Settings](https://user-images.githubusercontent.com/578572/129113477-21d1558a-6c24-4bd3-81b9-37f746f40de8.png)
