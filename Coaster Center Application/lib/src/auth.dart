
// lib/src/auth.dart

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

// StreamProvider สำหรับติดตามสถานะการล็อกอินของ Firebase User
final authStateProvider = StreamProvider<User?>(
  (ref) => ref.watch(firebaseAuthProvider).authStateChanges(),
);

// AuthService สำหรับจัดการ Google Sign-In และ Firebase Authentication
class AuthService {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _initialized = false;

  AuthService(this._auth) {
    _initialize();
  }

  Future<void> _initialize() async {
    if (!_initialized) {
      try {
        await _googleSignIn.initialize();
        _initialized = true;
      } catch (e) {
        // handle initialization error if needed
        print('GoogleSignIn initialization error: $e');
      }
    }
  }

  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await _initialize();
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    await _ensureInitialized();

    try {
      // ใช้ authenticate() ตาม google_sign_in v7
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate(
        scopeHint: ['email', 'profile'],
      );

      // ขอ authorization token
      final authClient = _googleSignIn.authorizationClient;
      final authorization = await authClient.authorizationForScopes(['email', 'profile']);

      if (authorization == null) {
        throw Exception('Authorization failed or was denied');
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: authorization.accessToken,
        idToken: authorization.idToken, // idToken อาจจะต้องแก้ไขถ้าไม่มีใน authorization
      );

      final userCredential = await _auth.signInWithCredential(credential);

      return userCredential;
    } on GoogleSignInException catch (e) {
      print('GoogleSignInException: code=${e.code.name}, description=${e.description}');
      rethrow;
    } catch (e) {
      print('SignInWithGoogle error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}

// Provider สำหรับ AuthService
final authServiceProvider = Provider<AuthService>(
  (ref) => AuthService(ref.watch(firebaseAuthProvider)),
);

