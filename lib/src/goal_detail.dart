import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firestore_service.dart';

class GoalDetail extends StatefulWidget {
  final Map<String, dynamic> goal;

  const GoalDetail({super.key, required this.goal});

  @override
  State<GoalDetail> createState() => _GoalDetailState();
}

class _GoalDetailState extends State<GoalDetail> {
  late double progress;
  late TextEditingController titleCtrl;

  @override
  void initState() {
    super.initState();
    progress = (widget.goal['progress'] ?? 0).toDouble();
    titleCtrl = TextEditingController(text: widget.goal['title'] ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final goalId = widget.goal['id'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Goal Detail'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'Goal Title'),
              onChanged: (val) {
                firestoreService.saveGoal(uid, goalId, {'title': val});
              },
            ),
            const SizedBox(height: 20),
            Slider(
              value: progress,
              min: 0,
              max: 100,
              divisions: 100,
              label: '${progress.round()}%',
              onChanged: (val) {
                setState(() => progress = val);
                firestoreService.saveGoal(uid, goalId, {'progress': val});
              },
            ),
          ],
        ),
      ),
    );
  }
}

