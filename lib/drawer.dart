import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

class EntryFormPageWidget extends StatefulWidget {
  EntryFormPageWidget() : super();

  @override
  _EntryFormPageWidgetState createState() => _EntryFormPageWidgetState();
}

class _EntryFormPageWidgetState extends State<EntryFormPageWidget> {
  bool switchListTileValue1 = false;
  bool switchListTileValue2 = false;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      drawer: Drawer(
        elevation: 16,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Icon(
              Icons.settings_outlined,
              color: Colors.black,
              size: 24,
            ),
            SwitchListTile(
              value: switchListTileValue1,
              onChanged: (newValue) =>
                  setState(() => switchListTileValue1 = newValue),
              title: Text(
                'Title',
              ),
              subtitle: Text(
                'Subtitle',
              ),
              tileColor: Color(0xFFF5F5F5),
              dense: false,
              controlAffinity: ListTileControlAffinity.trailing,
            ),
            SwitchListTile(
              value: switchListTileValue2,
              onChanged: (newValue) =>
                  setState(() => switchListTileValue2 = newValue),
              title: Text(
                'Title',
              ),
              subtitle: Text(
                'Subtitle',
              ),
              tileColor: Color(0xFFF5F5F5),
              dense: false,
              controlAffinity: ListTileControlAffinity.trailing,
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Hello World',
                  ),
                ),
                Expanded(
                  child: IconButton(
                    onPressed: () {
                      print('IconButton pressed ...');
                    },
                    icon: Icon(
                      Icons.add_box_outlined,
                      color: Colors.black,
                      size: 30,
                    ),
                    iconSize: 30,
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
