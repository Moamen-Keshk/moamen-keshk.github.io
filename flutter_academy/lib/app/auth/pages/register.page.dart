import 'package:flutter/material.dart';
import 'package:flutter_academy/app/auth/views/register.view.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: RegisterView()),
    );
  }
}
