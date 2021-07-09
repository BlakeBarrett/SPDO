import 'package:flutter/material.dart';

@immutable
class AnalogGauge extends StatelessWidget {
  AnalogGauge({required final this.speed, final this.maxSpeed = 90}) : super();
  final double speed; // meters per second
  final int maxSpeed;

  @override
  Widget build(BuildContext context) {
    // for example: ((180 / 90) * 65) / 180) === ((2) * 65) / 180) == 130º / 180º = 1.5 radians.
    var angle = ((180 / maxSpeed) * this.speed) / 180;
    return AngledNeedle(angle: angle);
  }
}

@immutable
class AngledNeedle extends StatelessWidget {
  AngledNeedle({required final this.angle}) : super();
  final double angle;
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var width = size.width;
    var height = size.height;
    var y = height - (height / 5);
    var tip = Offset(0, y);
    var pivot = Offset(width / 2, y);

    Widget line = Container(
        width: width,
        height: height,
        child: CustomPaint(
          painter: _LinePainter(
              origin: tip,
              destination: pivot,
              thickness: 20,
              color: Colors.redAccent),
        ));
    return Transform.rotate(angle: angle, origin: pivot, child: line);
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
