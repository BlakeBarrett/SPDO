import 'package:flutter/material.dart';
import 'dart:math' as math;

@immutable
class AnalogGauge extends StatelessWidget {
  AnalogGauge(
      {required final this.speed,
      required this.maxSpeed,
      this.color = Colors.redAccent})
      : super();

  final double speed;
  final int maxSpeed;
  final Color color;

  @override
  Widget build(BuildContext context) {
    var angle = this.speed * (math.pi / this.maxSpeed);
    return AngledNeedle(angle: angle, color: color);
  }
}

@immutable
class AngledNeedle extends StatelessWidget {
  AngledNeedle({required final this.angle, required this.color}) : super();
  final double angle;
  final Color color;
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var width = size.width / 2;
    var height = size.height - (size.height / 5);
    var tip = Offset(0, height);
    var pivot = Offset(width, height);

    Widget line = Container(
        width: width,
        height: height,
        child: CustomPaint(
          painter: _LinePainter(
              origin: tip, destination: pivot, thickness: 20, color: color),
        ));
    return Transform.rotate(
        angle: angle, alignment: Alignment.bottomRight, child: line);
  }
}

class _LinePainter extends CustomPainter {
  _LinePainter(
      {required final this.origin,
      required final this.destination,
      required final this.thickness,
      required final this.color})
      : super();

  Offset origin, destination;
  Color color;
  int thickness;

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = this.color
      ..style = PaintingStyle.fill;

    var path = Path();

    path.moveTo(this.origin.dx, this.origin.dy);
    path.lineTo(this.destination.dx, this.origin.dy - (thickness / 2));
    path.lineTo(this.destination.dx, this.origin.dy + (thickness / 2));
    path.lineTo(this.origin.dx, this.origin.dy);
    path.close();

    canvas.drawPath(path, paint);

    canvas.drawCircle(this.destination, (this.thickness.toDouble()), paint);
  }

  @override
  bool shouldRepaint(CustomPainter _) => true;
}
