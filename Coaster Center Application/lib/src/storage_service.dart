import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const _goalsKey = 'goals_v1';
  static Future<List<Map<String,dynamic>>> loadGoals() async {
    final p = await SharedPreferences.getInstance();
    final s = p.getString(_goalsKey);
    if (s == null) return [];
    final list = json.decode(s) as List;
    return list.map((e)=> Map<String,dynamic>.from(e)).toList();
  }

  static Future<void> saveGoals(List<Map<String,dynamic>> goals) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_goalsKey, json.encode(goals));
  }
}
