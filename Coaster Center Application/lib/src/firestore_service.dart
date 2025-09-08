import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> goalsRef(String uid) =>
      _db.collection('users').doc(uid).collection('goals');

  Stream<List<Map<String, dynamic>>> watchGoals(String uid) {
    return goalsRef(uid)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((s) => s.docs
            .map((d) => {...d.data(), 'id': d.id})
            .toList());
  }

  Future<void> saveGoal(String uid, String id, Map<String, dynamic> data) async {
    await goalsRef(uid).doc(id).set(data, SetOptions(merge: true));
  }

  Future<String> addGoal(String uid, Map<String, dynamic> data) async {
    final doc = await goalsRef(uid).add(data);
    return doc.id;
  }
}

final firestoreService = FirestoreService();

