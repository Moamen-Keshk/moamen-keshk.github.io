import 'package:flutter/material.dart';
import 'package:flutter_academy/routes/app_route_parser.dart';
import 'package:flutter_academy/routes/router_delegate.dart';

void main() {
  runApp(MyApp());
}

final routerDelegate = AppRouterDelegate();

class MyApp extends StatelessWidget {
  final _routeParser = AppRouteInformationParser();

  MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routerDelegate: routerDelegate,
      routeInformationParser: _routeParser,
    );
  }
}
