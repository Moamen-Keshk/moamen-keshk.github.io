import 'package:flutter/material.dart';
import 'package:lotel_pms/app/auth/views/register.view.dart';
import 'package:lotel_pms/app/api/widgets/adaptive_layout.widget.dart';
import 'package:lotel_pms/app/api/widgets/form_nav.widget.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PublicPageScaffold(
      body: ListView(
        children: const <Widget>[
          FormNav(),
          SizedBox(height: 20),
          Center(child: RegisterView())
        ],
      ),
    );
  }
}
