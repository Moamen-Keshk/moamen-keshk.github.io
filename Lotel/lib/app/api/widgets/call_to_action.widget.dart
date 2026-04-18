import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lotel_pms/app/api/res/responsive.res.dart';

class CallToAction extends StatelessWidget {
  const CallToAction({super.key});

  @override
  Widget build(BuildContext context) {
    final isCompact = context.showCompactLayout;
    return Container(
      margin: EdgeInsets.only(top: isCompact ? 24 : 40),
      color: Colors.grey.shade200,
      constraints: BoxConstraints(minHeight: isCompact ? 280 : 400),
      alignment: Alignment.center,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.responsiveHorizontalPadding,
          vertical: isCompact ? 32 : 48,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Ready to Begin Learning",
              style: isCompact
                  ? Theme.of(context).textTheme.headlineMedium
                  : Theme.of(context).textTheme.displayMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20.0),
            SizedBox(
              width: isCompact ? double.infinity : 180,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(
                      isCompact ? double.infinity : 180, isCompact ? 52 : 50),
                ),
                onPressed: () {
                  if (kDebugMode) {
                    print("register");
                  }
                },
                child: const Text("Get Started"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
