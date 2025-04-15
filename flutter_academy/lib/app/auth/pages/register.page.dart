import 'package:flutter/material.dart';
import 'package:flutter_academy/app/auth/views/register.view.dart';
import 'package:flutter_academy/app/courses/res/responsive.res.dart';
import 'package:flutter_academy/app/courses/widgets/form_nav.widget.dart';
import 'package:flutter_academy/app/courses/widgets/home_drawer.widget.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: const <Widget>[
          FormNav(),
          SizedBox(height: 20),
          Center(child: RegisterView())
        ],
      ),
      drawer: MediaQuery.of(context).size.width > ScreenSizes.md
          ? null
          : const DrawerNav(), //chaged to FormDrawerNav
    );
  }
}
