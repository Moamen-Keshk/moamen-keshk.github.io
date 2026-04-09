import 'package:flutter/material.dart';
import 'package:lotel_pms/app/auth/views/login.view.dart';
import 'package:lotel_pms/app/api/res/responsive.res.dart';
import 'package:lotel_pms/app/api/widgets/form_nav.widget.dart';
import 'package:lotel_pms/app/api/widgets/home_drawer.widget.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: const <Widget>[
          FormNav(),
          SizedBox(height: 20),
          Center(child: LoginView())
        ],
      ),
      drawer: MediaQuery.of(context).size.width > ScreenSizes.md
          ? null
          : const DrawerNav(), //chaged to FormDrawerNav
    );
  }
}
