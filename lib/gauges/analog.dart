import 'package:flutter/material.dart';
import 'dart:math' as math;

@immutable
class AnalogGauge extends StatelessWidget {
  const AnalogGauge(
      {super.key, required this.speed,
      required this.maxSpeed,
      this.color = Colors.redAccent});

  final double speed;
  final int maxSpeed;
  final Color color;

  @override
  Widget build(BuildContext context) {
    var angle = speed * (math.pi / maxSpeed);
    return AngledNeedle(angle: angle, color: color);
  }
}

@immutable
class AngledNeedle extends StatelessWidget {
  const AngledNeedle({super.key, required this.angle, required this.color});
  final double angle;
  final Color color;
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var width = size.width / 2;
    var height = size.height - (size.height / 5);
    var tip = Offset(0, height);
    var pivot = Offset(width, height);

    Widget line = SizedBox(
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
      {required this.origin,
      required this.destination,
      required this.thickness,
      required this.color})
      : super();

  Offset origin, destination;
  Color color;
  int thickness;

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    var path = Path();

    path.moveTo(origin.dx, origin.dy);
    path.lineTo(destination.dx, origin.dy - (thickness / 2));
    path.lineTo(destination.dx, origin.dy + (thickness / 2));
    path.lineTo(origin.dx, origin.dy);
    path.close();

    canvas.drawPath(path, paint);

    canvas.drawCircle(destination, (thickness.toDouble()), paint);
  }

  @override
  bool shouldRepaint(CustomPainter _) => true;
}
