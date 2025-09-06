import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth.dart';
import 'hex_dashboard.dart';

// Simple app scaffold. This prototype uses local auth (no Firebase) so it runs out-of-the-box.
// Firebase hooks are left as comments/placeholders in other files.

class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    return MaterialApp(
      title: 'Goal Planner Prototype',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: false,
      ),
      home: user == null ? SignInPage() : HexDashboard(),
    );
  }
}
