import 'package:flutter/material.dart';

@immutable
class AnalogGauge extends StatelessWidget {
  AnalogGauge({required final this.speed}) : super();

  final int speed;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: CustomPaint(
          painter: _AnalogGauge(speed: speed),
        ));
  }
}

class _AnalogGauge extends CustomPainter {
  _AnalogGauge({required final this.speed, final this.topSpeed = 90}) : super();
  int speed;
  int topSpeed;

  @override
  void paint(Canvas canvas, Size size) {
    var centerX = size.width / 2;
    var paint = Paint()
      ..color = Colors.redAccent
      ..style = PaintingStyle.fill;

    var path = Path();

    var topPoint = (speed / topSpeed) * centerX;

    path.moveTo(topPoint, 0);
    path.lineTo(centerX - 10, size.height);
    path.lineTo(centerX + 10, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter _) => true;
}
