import 'package:flutter/material.dart';
import 'package:lotel_pms/app/api/res/responsive.res.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    final width = context.screenWidth;
    final isCompact = context.showCompactLayout;
    return Container(
      color: Colors.grey.shade900,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20.0),
          Flex(
            direction: getAxis(width),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isCompact) const SizedBox(width: 20.0),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FooterLink("Home"),
                  FooterLink("About"),
                  FooterLink("Download Apps"),
                  FooterLink("Contact"),
                ],
              ),
              if (!isCompact) const Spacer(),
              if (isCompact) const SizedBox(height: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FooterLink("Blog"),
                  FooterLink("Help and Support"),
                  FooterLink("Join Us"),
                ],
              ),
              if (!isCompact) const Spacer(),
              if (isCompact) const SizedBox(height: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FooterLink("Terms"),
                  FooterLink("Privacy Policy"),
                ],
              ),
              if (!isCompact) const SizedBox(width: 20.0)
            ],
          ),
          const SizedBox(height: 20.0),
          Flex(
            direction: getAxis(width),
            children: [
              Padding(
                padding: isCompact
                    ? const EdgeInsets.all(0)
                    : const EdgeInsets.only(left: 30.0),
                child: Text(
                  "Lotel PMS",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                      ),
                ),
              ),
              isCompact ? const SizedBox(height: 10) : const Spacer(),
              Padding(
                padding: isCompact
                    ? const EdgeInsets.only(bottom: 10)
                    : const EdgeInsets.only(right: 30.0),
                child: Text(
                  "© 2018 Lotel PMS",
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30.0),
        ],
      ),
    );
  }
}

class FooterLink extends StatelessWidget {
  const FooterLink(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }
}
