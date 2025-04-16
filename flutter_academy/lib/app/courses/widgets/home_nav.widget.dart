import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_academy/app/courses/res/responsive.res.dart';
import 'package:flutter_academy/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TopNav extends ConsumerWidget {
  const TopNav({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBar(
      title: const Text('Lotel'),
      elevation: kIsWeb ? 0 : null,
      centerTitle: kIsWeb ? false : null,
      actions: (MediaQuery.of(context).size.width <= ScreenSizes.md)
          ? null
          : [
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.grey),
                onPressed: () {
                  ref.read(routerProvider).push('about');
                },
                child: const Text("About"),
              ),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.grey),
                onPressed: () {
                  ref.read(routerProvider).push('login');
                },
                child: const Text("Login"),
              ),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.grey),
                onPressed: () {
                  ref.read(routerProvider).push('contact');
                },
                child: const Text("Contact"),
              ),
            ],
    );
  }
}
