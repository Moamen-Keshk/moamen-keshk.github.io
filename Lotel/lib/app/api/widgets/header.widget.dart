import 'package:flutter/material.dart';
import 'package:lotel_pms/app/api/res/assets.res.dart';
import 'package:lotel_pms/app/api/res/responsive.res.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    final isCompact = context.showCompactLayout;
    return Container(
      constraints: BoxConstraints(minHeight: isCompact ? 360 : 500),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        image: DecorationImage(
          image: const AssetImage(Assets.instructor),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withValues(alpha: 0.7),
            BlendMode.srcATop,
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.responsiveHorizontalPadding,
          vertical: isCompact ? 32 : 40,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Welcome to Lotel",
              textAlign: TextAlign.center,
              style: (isCompact
                      ? Theme.of(context).textTheme.headlineLarge
                      : Theme.of(context).textTheme.displayMedium)
                  ?.copyWith(
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Text(
                "Your one stop education hub to learn Flutter.",
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
