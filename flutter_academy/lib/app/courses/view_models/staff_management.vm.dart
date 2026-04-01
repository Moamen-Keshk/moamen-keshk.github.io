import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_academy/app/req/request.dart'; // Using your existing request utility

class StaffManagementVM extends ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  bool isLoading = false;
  String error = '';

  Future<bool> sendInvite({
    required int propertyId,
    required String email,
    required int roleId,
  }) async {
    isLoading = true;
    error = '';
    notifyListeners();

    try {
      final token = await _auth.currentUser?.getIdToken();
      final success = await sendPostRequest(
        {
          'email': email,
          'role_id': roleId,
        },
        token,
        '/api/v1/properties/$propertyId/invites',
      );

      isLoading = false;

      if (success) {
        notifyListeners();
        return true;
      } else {
        error = 'Failed to send invite';
        notifyListeners();
        return false;
      }
    } catch (e) {
      error = 'A network error occurred while sending the invite.';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }
}

final staffManagementVM = ChangeNotifierProvider((ref) => StaffManagementVM());
