import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:spdo/main.dart';

Widget wrapWithMaterialApp(final Widget widget) {
  return MaterialApp(home: Scaffold(body: widget));
}

void main() {
  testWidgets('Tests rendering a GaugeWidget',
      (final WidgetTester tester) async {
    await tester.pumpWidget(Builder(
      builder: (final BuildContext context) {
        return wrapWithMaterialApp(GaugeWidget(
            display: "69MPH",
            speed: 69,
            showAnalog: true,
            showTopSpeed: true,
            topSpeed: 75,
            maxSpeed: 85));
      },
    ));
  });
}
