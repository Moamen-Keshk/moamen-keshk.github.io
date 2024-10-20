import 'package:flutter/material.dart';
import 'package:flutter_academy/main.dart';

class SnackBarTunnel extends StatelessWidget {
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();
  final String message;
  final String path;

  SnackBarTunnel(String s, {super.key, required this.message, required this.path});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _scaffoldKey
        .currentState
        ?.showSnackBar(SnackBar(content: Text(message))));
    return routerDelegate.go(path);
  }
}
