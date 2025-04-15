import 'package:flutter/material.dart';
import 'package:flutter_academy/app/auth/views/login.view.dart';
import 'package:flutter_academy/app/courses/res/responsive.res.dart';
import 'package:flutter_academy/app/courses/widgets/form_nav.widget.dart';
import 'package:flutter_academy/app/courses/widgets/home_drawer.widget.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: const <Widget>[FormNav(), Center(child: LoginView())],
      ),
      drawer: MediaQuery.of(context).size.width > ScreenSizes.md
          ? null
          : const DrawerNav(), //chaged to FormDrawerNav
    );
  }
}
