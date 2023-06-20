import 'package:flutter/material.dart';
import 'package:flutter_academy/app/auth/views/email_verification.view.dart';

class EmailVerificationPage extends StatelessWidget {
  const EmailVerificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: EmailVerificationView()),
    );
  }
}
