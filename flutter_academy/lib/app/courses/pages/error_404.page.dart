import 'package:flutter/material.dart';
import 'package:flutter_academy/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Error404Page extends ConsumerStatefulWidget {
  const Error404Page({super.key});

  @override
  ConsumerState<Error404Page> createState() => _Error404PageState();
}

class _Error404PageState extends ConsumerState<Error404Page> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '404 - Page Not Found',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              child: const Text('Go to Home'),
              onPressed: () {
                ref.read(routerProvider).replaceAllWith('home');
              },
            ),
          ],
        ),
      ),
    );
  }
}
