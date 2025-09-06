import 'dart:ui';

abstract class BoardObject {
  String id;
  double x;
  double y;
  double scale;
  double rotation;
  String type;
  Map<String,dynamic> data;
  BoardObject({
    required this.id,
    required this.x,
    required this.y,
    this.scale = 1.0,
    this.rotation = 0.0,
    required this.type,
    Map<String,dynamic>? data,
  }) : data = data ?? {};
}

class PathObject extends BoardObject {
  // points stored relative to object's origin
  List<List<double>> points;
  PathObject({
    required String id,
    required double x,
    required double y,
    this.points = const [],
  }) : super(id: id, x: x, y: y, type: 'path', data: {'points': points});
}
