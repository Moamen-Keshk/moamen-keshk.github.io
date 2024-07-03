import 'package:flutter/material.dart';
import 'package:flutter_academy/app/courses/res/assets.res.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500.0,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        image: DecorationImage(
          image: const AssetImage(Assets.instructor),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.7),
            BlendMode.srcATop,
          ),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40.0),
          Text(
            "Welcome to Lotel",
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: Colors.white,
                ),
          ),
          Text(
            "Your one stop education hub to learn Flutter.",
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
