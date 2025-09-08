import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'board_painter.dart';
import 'board_state.dart';

class BoardPage extends ConsumerStatefulWidget {
  final String boardId;
  BoardPage({required this.boardId});
  @override
  ConsumerState<BoardPage> createState() => _BoardPageState();
}

class _BoardPageState extends ConsumerState<BoardPage> {
  List<Offset> current = [];
  @override
  Widget build(BuildContext context) {
    final objects = ref.watch(boardProvider);
    return Scaffold(
      appBar: AppBar(title: Text('Drawboard')),
      body: InteractiveViewer(
        minScale: 0.5,
        maxScale: 4,
        boundaryMargin: EdgeInsets.all(200),
        child: GestureDetector(
          onPanStart: (d){
            final box = context.findRenderObject() as RenderBox;
            final p = box.globalToLocal(d.globalPosition);
            setState(() => current = [p]);
          },
          onPanUpdate: (d){
            final box = context.findRenderObject() as RenderBox;
            final p = box.globalToLocal(d.globalPosition);
            setState(()=> current = [...current, p]);
          },
          onPanEnd: (d){
            final pts = current.map((o)=> [o.dx, o.dy]).toList();
            ref.read(boardProvider.notifier).addPath(pts);
            setState(()=> current = []);
          },
          child: CustomPaint(
            size: Size(2000,2000),
            painter: _CombinedPainter(objects: objects, current: current),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ref.read(boardProvider.notifier).clear(),
        child: Icon(Icons.delete),
      ),
    );
  }
}

class _CombinedPainter extends CustomPainter {
  final List objects;
  final List<Offset> current;
  _CombinedPainter({required this.objects, required this.current});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.stroke..strokeWidth = 3.0..color = Colors.black;
    for (final o in objects) {
      if (o.type == 'path') {
        final pts = List<List<double>>.from(o.data['points'] ?? []);
        if (pts.length>=2) {
          final path = Path();
          path.moveTo(pts[0][0], pts[0][1]);
          for (var i=1;i<pts.length;i++) path.lineTo(pts[i][0], pts[i][1]);
          canvas.drawPath(path, paint);
        }
      }
    }
    if (current.length>=2) {
      final path = Path()..moveTo(current[0].dx, current[0].dy);
      for (var i=1;i<current.length;i++) path.lineTo(current[i].dx, current[i].dy);
      canvas.drawPath(path, paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
