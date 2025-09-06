import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models.dart';
import 'package:uuid/uuid.dart';
final boardProvider = StateNotifierProvider<BoardNotifier, List<BoardObject>>((ref) => BoardNotifier());
final uuid = Uuid();

class BoardNotifier extends StateNotifier<List<BoardObject>> {
  BoardNotifier(): super([]);
  void addPath(List<List<double>> pts) {
    final obj = PathObject(id: uuid.v4(), x:0, y:0, points: pts);
    state = [...state, obj];
  }
  void clear() => state = [];
}
