import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lotel_pms/app/api/res/responsive.res.dart';

class FormNav extends StatelessWidget {
  const FormNav({super.key});

  @override
  Widget build(BuildContext context) {
    final isCompact = context.showCompactLayout;
    return AppBar(
      title: const Text('Lotel'),
      elevation: kIsWeb ? 0 : null,
      centerTitle: isCompact ? true : (kIsWeb ? false : null),
      actions: isCompact ? null : const [],
    );
  }
}
