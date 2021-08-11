import 'package:flutter_test/flutter_test.dart';

import 'package:spdo/main.dart';

void main() {
  testWidgets('Tests metric to imperial conversion math',
      (WidgetTester tester) async {
    var speedListener = SpeedListenerWidget();

    var metersPerSecond = 7.20;
    var kph = speedListener.msToKPH(metersPerSecond);
    expect(kph, 25.92);

    var mph = speedListener.kphToMPH(kph);
    expect(mph, 16.109384711000622);

    var display = speedListener.displaySpeed(mph, false);
    expect(display, '16MPH');
  });
}
