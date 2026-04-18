import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lotel_pms/app/api/res/responsive.res.dart';
import 'package:lotel_pms/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TopNav extends ConsumerWidget {
  const TopNav({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCompact = context.showCompactLayout;
    return AppBar(
      title: const Text('Lotel'),
      elevation: kIsWeb ? 0 : null,
      centerTitle: isCompact ? true : (kIsWeb ? false : null),
      actions: isCompact
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
