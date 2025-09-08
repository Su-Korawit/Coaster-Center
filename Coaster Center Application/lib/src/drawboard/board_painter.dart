import 'package:flutter/material.dart';
import 'models.dart';

class BoardPainter extends CustomPainter {
  final List<BoardObject> objects;
  BoardPainter({required this.objects});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.black;
    for (final o in objects) {
      if (o.type == 'path') {
        final pts = List<List<double>>.from(o.data['points'] ?? []);
        if (pts.length < 2) continue;
        final path = Path();
        path.moveTo(pts[0][0], pts[0][1]);
        for (var i=1;i<pts.length;i++) path.lineTo(pts[i][0], pts[i][1]);
        canvas.drawPath(path, paint);
      }
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
