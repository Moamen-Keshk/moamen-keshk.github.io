import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lotel_pms/app/users/view_models/user.vm.dart';
import 'package:lotel_pms/app/req/request.dart';
import 'package:flutter_riverpod/legacy.dart';

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

  // UPDATED: Now accepts an optional inviteCode
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String? inviteCode,
  }) async {
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      // Build the request body dynamically
      final Map<String, dynamic> body = {
        "username": name,
        "email": email,
        "password": password
      };

      // If an invite code was provided, attach it to the backend payload
      if (inviteCode != null && inviteCode.isNotEmpty) {
        body["invite_code"] = inviteCode;
      }

      if (!await sendPostRequest(
          body, await _auth.currentUser?.getIdToken(), "/auth/register")) {
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

  Future<void> checkEmailVerified() async {
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
    _subscription = _auth.authStateChanges().listen((user) async {
      if (user == null) {
        isLoggedIn = false;
        this.user = null;
        notifyListeners();
      } else {
        // 1. Initial assignment with Firebase data
        this.user = UserVM(
            email: user.email ?? 'N/A',
            name: user.displayName ?? 'N/A',
            id: user.uid);

        isLoggedIn = true;
        notifyListeners();

        // 2. Fetch extended user data (Role, Account Status) from your backend
        await syncWithBackend();
      }
    });
  }

  Future<bool> syncWithBackend({int? propertyId}) async {
    if (_auth.currentUser == null) {
      error = 'No authenticated user found.';
      notifyListeners();
      return false;
    }

    try {
      String? token = await _auth.currentUser?.getIdToken();

      final response = await sendGetWithParamsRequestOrThrow(
        token,
        "/api/v1/users",
        {
          'property_id': propertyId?.toString(),
        },
        fallbackMessage: 'Failed to load account status from the backend.',
      );

      if (response != null && response['status'] == 'success') {
        final data = response['data'];
        final permissions = (data['permissions'] as List?)
                ?.whereType<String>()
                .toList() ??
            const <String>[];

        user = user?.copyWith(
          accountStatusId: data['account_status_id'] ?? 1,
          role: data['role_name'],
          propertyId: data['property_id'],
          permissions: permissions,
          isSuperAdmin: data['is_super_admin'] == true,
        );
        error = '';
        notifyListeners();
        return true;
      }

      error = 'Failed to load account status from the backend.';
      notifyListeners();
      return false;
    } on ApiRequestException catch (e) {
      error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      error = "Failed to sync with backend: $e";
      notifyListeners();
      return false;
    }
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
