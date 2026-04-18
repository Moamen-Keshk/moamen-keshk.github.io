import 'package:flutter/material.dart';
import 'package:lotel_pms/app/api/res/responsive.res.dart';

class FeaturedSection extends StatelessWidget {
  const FeaturedSection({
    super.key,
    required this.image,
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.onActionPressed,
    this.imageLeft = true,
  });

  final bool imageLeft;
  final String image;
  final String title;
  final String description;
  final String buttonLabel;
  final Function() onActionPressed;

  @override
  Widget build(BuildContext context) {
    final width = context.screenWidth;
    final isCompact = context.showCompactLayout;
    return Container(
      height: isCompact ? null : null,
      padding: EdgeInsets.all(isCompact ? 20.0 : 32.0),
      child: Flex(
        direction: getAxis(width),
        children: [
          if (imageLeft)
            Expanded(
              child: Image.asset(
                image,
                height: isCompact ? 260 : 450,
              ),
            ),
          SizedBox(width: isCompact ? 0 : 20.0, height: isCompact ? 20.0 : 0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 20.0),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 18.0,
                      ),
                ),
                const SizedBox(height: 20.0),
                Center(
                  child: ElevatedButton(
                    onPressed: onActionPressed,
                    child: Text(buttonLabel),
                  ),
                )
              ],
            ),
          ),
          SizedBox(width: isCompact ? 0 : 20.0, height: isCompact ? 20.0 : 0),
          if (!imageLeft)
            Expanded(
              child: Image.asset(
                image,
                height: isCompact ? 260 : 450,
              ),
            ),
        ],
      ),
    );
  }
}
