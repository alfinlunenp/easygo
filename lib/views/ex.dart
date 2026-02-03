import 'package:flutter/material.dart';


class LocationPinsApp extends StatelessWidget {
  const LocationPinsApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vertical Dotted Line with Pins',
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [












              
              // Top pin
              Icon(
                Icons.location_on,
                size: 32,
                color: Colors.teal[700],
              ),

              // Dotted line
              SizedBox(
                height: 40,
                child: CustomPaint(
                  painter: DottedLinePainter(color: Colors.teal[700]!),
                  child: const SizedBox(width: 2),
                ),
              ),

              // Bottom pin
              Icon(
                Icons.location_on,
                size: 32,
                color: Colors.teal[700],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DottedLinePainter extends CustomPainter {
  final Color color;
  final double dotRadius;
  final double space;

  DottedLinePainter({
    required this.color,
    this.dotRadius = 2,
    this.space = 6,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    double y = 0;
    final centerX = size.width / 2;

    while (y < size.height) {
      canvas.drawCircle(Offset(centerX, y), dotRadius, paint);
      y += dotRadius * 2 + space;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
