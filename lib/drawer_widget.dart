import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:package_info/package_info.dart';

import 'image_picker_utils.dart';
import 'settings.dart';

@immutable
class DrawerWidget extends StatefulWidget {
  const DrawerWidget({super.key});

  @override
  _DrawerWidgetState createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  final String displayMetric = "km/h";
  final String displayImperial = "MPH";
  String unitsSubtitle = "MPH | km/h";

  PackageInfo? packageInfo;
  late Settings settings;

  final sliderColor = const Color(0xFFF5F5F5);
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final iconSize = 24.0;

  @override
  void initState() {
    super.initState();
    loadPreferences();
    loadPlatformInfo();
  }

  void loadPreferences() async {
    settings = await Settings.getInstance();
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
        const Icon(Icons.image),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => ImagePickerUtils.clearImage(),
        ),
      ]),
      onTap: () => ImagePickerUtils.browseForImage(),
    );
  }

  Widget unitSelectionWidget() {
    return SwitchListTile(
      value: settings.metric,
      onChanged: (newValue) => setState(() {
        settings.metric = newValue;
      }),
      title: Text(unitsSubtitle, style: const TextStyle(fontWeight: FontWeight.bold)),
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
      value: settings.digital,
      onChanged: (newValue) => setState(() {
        settings.digital = newValue;
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
      value: settings.analog,
      onChanged: (newValue) => setState(() {
        settings.analog = newValue;
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
        padding:
            EdgeInsets.only(left: Platform.isAndroid ? 16.0 : 0.0, right: 24.0),
        child: Row(
          children: [
            if (!Platform.isAndroid) ...[const Spacer()],
            SvgPicture.asset('assets/max-speed.svg',
                width: iconSize, height: iconSize, color: Colors.red),
            const Spacer(),
            const Text(
              "Max Speed",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(
                width: iconSize * 2, height: iconSize * 2, child: actionWidget),
            Text(
              settings.metric ? "km/h" : "MPH",
              style: const TextStyle(fontWeight: FontWeight.bold),
            )
          ],
        ));
  }

  void showEditPopup(BuildContext context) {
    var popup = SimpleDialog(
      children: [
        maxSpeedEditWidget(
          TextField(
            decoration: InputDecoration(
                labelText: settings.maxSpeed.toString(),
                contentPadding: const EdgeInsets.only(left: 12.0, right: 12.0)),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ], // Only numbers can be entered
            onChanged: (newValue) => setState(() {
              try {
                settings.maxSpeed = int.parse(newValue);
              } catch (e) {
                print(e);
              }
            }),
          ),
        )
      ],
    );
    showDialog(context: context, builder: (context) => popup);
  }

  Widget maxSpeedWidget() {
    if (settings.analog) {
      return maxSpeedEditWidget(TextButton(
        autofocus: true,
        child: Text(settings.maxSpeed.toString()),
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
      value: settings.showTopSpeed,
      onChanged: (newValue) => setState(() {
        settings.showTopSpeed = newValue;
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
      applicationName: 'SPDO',
      applicationVersion:
          "${packageInfo?.version} build:${packageInfo?.buildNumber}",
      aboutBoxChildren: const [
        Center(
          child: Text("It's a speedometer."),
        ),
      ],
    );
  }

  @override
  void dispose() {
    settings.writePreferences();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Wait until we've actually finished loading everything we need.
    if (packageInfo == null) {
      return const Column();
    }

    return Drawer(
      child: Flex(direction: Axis.vertical, children: [
        Expanded(
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              backgroundChooserWidget(),
              unitSelectionWidget(),
              digitalSpeedWidget(),
              analogSpeedWidget(),
              maxSpeedWidget(),
              topSpeedWidget(),
            ],
          ),
        ),
        aboutWidget(),
      ]),
    );
  }
}

Widget settingsDrawerDisclosureIconButtonWidget(BuildContext context) {
  return Positioned(
      bottom: 0.0,
      left: 0.0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: IconButton(
          icon: const Icon(
            Icons.settings,
            color: Colors.black12,
          ),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ));
}
