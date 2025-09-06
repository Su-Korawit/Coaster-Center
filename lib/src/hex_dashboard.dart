import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'firestore_service.dart';
import 'goal_detail.dart';
import 'auth.dart';

final goalsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return const Stream.empty();
  return firestoreService.watchGoals(user.uid);
});

class HexDashboard extends ConsumerWidget {
  const HexDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(goalsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Goals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authServiceProvider).signOut(),
          ),
        ],
      ),
      body: goalsAsync.when(
        data: (goals) {
          return Center(
            child: Wrap(
              spacing: -20,
              runSpacing: -15,
              children: goals.map((goal) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => GoalDetail(goal: goal),
                    ));
                  },
                  child: HexagonWidget(
                    title: goal['title'] ?? '',
                    progress: (goal['progress'] ?? 0).toDouble(),
                  ),
                );
              }).toList(),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final uid = FirebaseAuth.instance.currentUser!.uid;
          await firestoreService.addGoal(uid, {
            'title': 'New Goal',
            'progress': 0,
            'createdAt': FieldValue.serverTimestamp(),
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class HexagonWidget extends StatelessWidget {
  final String title;
  final double progress; // 0.0 - 100.0

  const HexagonWidget({
    super.key,
    required this.title,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: HexagonPainter(progress: progress / 100),
      child: SizedBox(
        width: 120,
        height: 104,
        child: Center(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

class HexagonPainter extends CustomPainter {
  final double progress; // 0.0 - 1.0

  HexagonPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final hexPath = _createHexagonPath(size);
    final paintBg = Paint()..color = Colors.grey.shade300;
    final paintFill = Paint()..color = Colors.blue;

    canvas.drawPath(hexPath, paintBg);

    final fillHeight = size.height * progress;
    final clipPath = Path()
      ..addRect(Rect.fromLTWH(0, size.height - fillHeight, size.width, fillHeight));

    canvas.save();
    canvas.clipPath(hexPath);
    canvas.drawRect(
      Rect.fromLTWH(0, size.height - fillHeight, size.width, fillHeight),
      paintFill,
    );
    canvas.restore();

    final borderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(hexPath, borderPaint);
  }

  Path _createHexagonPath(Size size) {
    final w = size.width;
    final h = size.height;
    return Path()
      ..moveTo(w * 0.25, 0)
      ..lineTo(w * 0.75, 0)
      ..lineTo(w, h * 0.5)
      ..lineTo(w * 0.75, h)
      ..lineTo(w * 0.25, h)
      ..lineTo(0, h * 0.5)
      ..close();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

