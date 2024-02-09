import 'package:flutter/material.dart';
import 'package:flutter_academy/app/auth/views/reset_password.view.dart';

class ResetPasswordPage extends StatelessWidget {
  const ResetPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: ResetPasswordView()),
    );
  }
}
