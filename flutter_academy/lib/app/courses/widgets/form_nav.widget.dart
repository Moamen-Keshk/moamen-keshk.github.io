import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_academy/app/courses/res/responsive.res.dart';

class FormNav extends StatelessWidget {
  const FormNav({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Lotel'),
      elevation: kIsWeb ? 0 : null,
      centerTitle: kIsWeb ? false : null,
      actions:
          (MediaQuery.of(context).size.width <= ScreenSizes.md) ? null : [],
    );
  }
}
