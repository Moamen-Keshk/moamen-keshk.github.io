import 'package:flutter/material.dart';
import 'package:lotel_pms/app/api/widgets/adaptive_layout.widget.dart';
import 'package:lotel_pms/app/api/widgets/home_drawer.widget.dart';
import 'package:lotel_pms/app/api/widgets/home_nav.widget.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PublicPageScaffold(
      drawer: const DrawerNav(),
      body: ListView(
        children: const <Widget>[
          TopNav(),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("About Page"),
          )
        ],
      ),
    );
  }
}
