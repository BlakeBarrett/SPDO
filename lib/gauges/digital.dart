import 'package:flutter/material.dart';

class DigitalGauge extends StatelessWidget {
  const DigitalGauge({
    Key? key,
    required String value,
  })  : _value = value,
        super(key: key);

  final String _value;

  @override
  Widget build(BuildContext context) {
    return Text(
      _value,
      style: Theme.of(context).textTheme.displayLarge,
    );
  }
}
