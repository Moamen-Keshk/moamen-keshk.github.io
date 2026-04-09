import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'login.view.dart';

class AuthHomeView extends StatelessWidget {
  const AuthHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        return const LoginView();
      },
    );
  }
}
