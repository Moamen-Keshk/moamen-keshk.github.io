import 'package:flutter/material.dart';
import 'package:lotel_pms/app/api/widgets/adaptive_layout.widget.dart';
import 'package:lotel_pms/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Error404Page extends ConsumerStatefulWidget {
  const Error404Page({super.key});

  @override
  ConsumerState<Error404Page> createState() => _Error404PageState();
}

class _Error404PageState extends ConsumerState<Error404Page> {
  @override
  Widget build(BuildContext context) {
    return PublicPageScaffold(
      body: ResponsiveContent(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '404 - Page Not Found',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: 220,
                child: ElevatedButton(
                  child: const Text('Go to Home'),
                  onPressed: () {
                    ref.read(routerProvider).replaceAllWith('home');
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
