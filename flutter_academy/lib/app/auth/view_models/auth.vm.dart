import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_academy/app/users/view_models/user.vm.dart';
import 'package:flutter_academy/app/req/request.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthVM extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoggedIn = false;
  bool isReset = false;
  String error = '';
  UserVM? user;
  StreamSubscription<User?>? _subscription;
  bool isEmailVerified = false;
  Timer? timer;

  AuthVM() {
    subscribe();
  }

  Future<bool> login({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      if (_auth.currentUser!.emailVerified) {
        isEmailVerified = true;
      }
      return true;
    } on FirebaseAuthException catch (e) {
      isLoggedIn = false;
      error = e.message ?? e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(
      {required String name,
      required String email,
      required String password}) async {
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      if (!await sendPostRequest(
          {"username": name, "email": email, "password": password},
          await _auth.currentUser?.getIdToken(),
          "/auth/register")) {
        _auth.currentUser?.delete();
        isLoggedIn = false;
        notifyListeners();
        return false;
      }
      verifyEmail();
      return true;
    } on FirebaseAuthException catch (e) {
      isLoggedIn = false;
      error = e.message ?? e.toString();
      notifyListeners();
      return false;
    }
  }

  void resetPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      isReset = true;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      error = e.message ?? e.toString();
    }
  }

  void verifyEmail() {
    // TODo: implement initState
    _auth.currentUser?.sendEmailVerification();
    timer =
        Timer.periodic(const Duration(seconds: 3), (_) => checkEmailVerified());
  }

  void verifyEmailVerfication() {
    // TODo: implement initState
    timer =
        Timer.periodic(const Duration(seconds: 3), (_) => checkEmailVerified());
  }

  checkEmailVerified() async {
    await _auth.currentUser?.reload();

    isEmailVerified = _auth.currentUser!.emailVerified;

    if (isEmailVerified) {
      // TODo: implement your code after email verification
      timer?.cancel();
      notifyListeners();
    }
  }

  Future<bool> anonymousLogin() async {
    if (isLoggedIn) {
      error = 'Already logged in';
      return false;
    }
    error = '';
    try {
      await _auth.signInAnonymously();
      return true;
    } on FirebaseAuthException catch (e) {
      error = e.message ?? e.toString();
      isLoggedIn = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> subscribe() async {
    _subscription = _auth.authStateChanges().listen((user) {
      if (user == null) {
        isLoggedIn = false;
        this.user = null;
        notifyListeners();
      } else {
        this.user = UserVM(
            email: user.email ?? 'N/A',
            name: user.displayName ?? 'N/A',
            id: user.uid);
        isLoggedIn = true;
        notifyListeners();
      }
    });
  }

  Future<bool> logout() async {
    if (!isLoggedIn) {
      error = 'Not logged in';
      return false;
    }
    try {
      await _auth.signOut();
      error = '';
      user = null;
      isLoggedIn = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      error = e.message ?? e.toString();
      return false;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _subscription?.cancel();
    timer?.cancel();
  }
}

final authVM = ChangeNotifierProvider<AuthVM>((ref) => AuthVM());
