import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_academy/app/courses/res/responsive.res.dart';

class CallToAction extends StatelessWidget {
  const CallToAction({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 40.0),
      color: Colors.grey.shade200,
      height: 400,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Ready to Begin Learning",
            style: Theme.of(context).textTheme.displayMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20.0),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              fixedSize: MediaQuery.of(context).size.width > ScreenSizes.md
                  ? const Size(180, 50)
                  : const Size(180, 70),
            ),
            onPressed: () {
              if (kDebugMode) {
                print("register");
              }
            },
            child: const Text("Get Started"),
          )
        ],
      ),
    );
  }
}
