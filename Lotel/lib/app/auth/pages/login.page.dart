import 'package:flutter/material.dart';
import 'package:lotel_pms/app/auth/views/login.view.dart';
import 'package:lotel_pms/app/api/widgets/adaptive_layout.widget.dart';
import 'package:lotel_pms/app/api/widgets/form_nav.widget.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PublicPageScaffold(
      body: ListView(
        children: const <Widget>[
          FormNav(),
          SizedBox(height: 20),
          Center(child: LoginView())
        ],
      ),
    );
  }
}
