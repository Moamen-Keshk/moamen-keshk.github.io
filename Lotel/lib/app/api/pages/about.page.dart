import 'package:flutter/material.dart';
import 'package:lotel_pms/app/api/res/responsive.res.dart';
import 'package:lotel_pms/app/api/widgets/home_drawer.widget.dart';
import 'package:lotel_pms/app/api/widgets/home_nav.widget.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: const <Widget>[
          TopNav(),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("About Page"),
          )
        ],
      ),
      drawer: MediaQuery.of(context).size.width > ScreenSizes.md
          ? null
          : const DrawerNav(),
    );
  }
}
