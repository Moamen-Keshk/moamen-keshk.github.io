import 'package:flutter/material.dart';
import 'package:flutter_academy/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SnackBarTunnel extends ConsumerWidget {
  final String message;
  final String path;

  const SnackBarTunnel({
    super.key,
    required this.message,
    required this.path,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Schedule navigation + snackbar after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      ref.read(routerProvider).replaceAllWith(path);
    });

    // Return empty container since navigation happens after frame
    return const SizedBox.shrink();
  }
}
