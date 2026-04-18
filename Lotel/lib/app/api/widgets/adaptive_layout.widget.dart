import 'package:flutter/material.dart';
import 'package:lotel_pms/app/api/res/responsive.res.dart';
import 'package:lotel_pms/app/api/view_models/lists/booking_list.vm.dart';
import 'package:lotel_pms/app/api/views/new_booking.view.dart';
import 'package:lotel_pms/app/api/widgets/dashboard_drawer.widget.dart';
import 'package:lotel_pms/app/api/widgets/dashboard_nav.widget.dart';
import 'package:lotel_pms/app/api/widgets/home_drawer.widget.dart';
import 'package:lotel_pms/app/auth/view_models/access_control.vm.dart';
import 'package:lotel_pms/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ResponsiveContent extends StatelessWidget {
  const ResponsiveContent({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
    this.alignment = Alignment.topCenter,
  });

  final Widget child;
  final double? maxWidth;
  final EdgeInsetsGeometry? padding;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final contentPadding = padding ??
        EdgeInsets.symmetric(
          horizontal: context.responsiveHorizontalPadding,
          vertical: context.responsiveVerticalPadding,
        );

    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? context.responsiveContentMaxWidth,
        ),
        child: Padding(
          padding: contentPadding,
          child: child,
        ),
      ),
    );
  }
}

class ResponsiveFormCard extends StatelessWidget {
  const ResponsiveFormCard({
    super.key,
    required this.child,
    this.maxWidth = 640,
    this.padding,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return ResponsiveContent(
      maxWidth: maxWidth,
      padding: padding ??
          EdgeInsets.symmetric(
            horizontal: context.responsiveHorizontalPadding,
            vertical: context.showCompactLayout ? 12 : 24,
          ),
      child: child,
    );
  }
}

class ResponsiveFormRow extends StatelessWidget {
  const ResponsiveFormRow({
    super.key,
    required this.children,
    this.spacing = 12,
  });

  final List<Widget> children;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    if (context.showCompactLayout) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _withVerticalSpacing(),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _withHorizontalSpacing(),
    );
  }

  List<Widget> _withVerticalSpacing() {
    return [
      for (var index = 0; index < children.length; index++) ...[
        children[index],
        if (index != children.length - 1) SizedBox(height: spacing),
      ],
    ];
  }

  List<Widget> _withHorizontalSpacing() {
    return [
      for (var index = 0; index < children.length; index++) ...[
        Expanded(child: children[index]),
        if (index != children.length - 1) SizedBox(width: spacing),
      ],
    ];
  }
}

class DashboardPageScaffold extends ConsumerWidget {
  const DashboardPageScaffold({
    super.key,
    required this.body,
    this.backgroundColor,
    this.resizeToAvoidBottomInset,
  });

  final Widget body;
  final Color? backgroundColor;
  final bool? resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.read(routerProvider);

    return AnimatedBuilder(
      animation: router,
      builder: (context, _) {
        final isCompact = context.showCompactLayout;
        final currentRoute = router.currentRouteName ?? 'dashboard';
        final canManageBookings =
            hasPmsPermission(ref, PmsPermission.manageBookings);
        final canViewBookings =
            hasPmsPermission(ref, PmsPermission.viewBookings);
        final canUpdateRoomStatus =
            hasPmsPermission(ref, PmsPermission.updateRoomStatus);
        final effectivePropertyId = ref.watch(effectivePropertyIdProvider);

        final bottomItems = <_DashboardBottomNavItem>[
          const _DashboardBottomNavItem(
            route: 'dashboard',
            icon: Icons.dashboard_outlined,
            activeIcon: Icons.dashboard,
            tooltip: 'Dashboard',
          ),
          if (canViewBookings)
            const _DashboardBottomNavItem(
              route: 'todays',
              icon: Icons.calendar_today_outlined,
              activeIcon: Icons.calendar_today,
              tooltip: "Today's",
            ),
          if (canViewBookings)
            const _DashboardBottomNavItem(
              route: 'booking_search',
              icon: Icons.search_outlined,
              activeIcon: Icons.search,
              tooltip: 'Bookings',
            ),
          if (canUpdateRoomStatus)
            const _DashboardBottomNavItem(
              route: 'housekeeping',
              icon: Icons.cleaning_services_outlined,
              activeIcon: Icons.cleaning_services,
              tooltip: 'Housekeeping',
            ),
        ];

        return Scaffold(
          backgroundColor: backgroundColor,
          resizeToAvoidBottomInset: resizeToAvoidBottomInset,
          appBar: const DashboardNav(),
          drawer: isCompact ? const DashboardDrawer() : null,
          floatingActionButton:
              isCompact && canManageBookings && currentRoute == 'dashboard'
                  ? FloatingActionButton(
                      heroTag: 'dashboard-new-booking-fab',
                      tooltip: 'New Booking',
                      onPressed: effectivePropertyId != null
                          ? () => _showMobileBookingDialog(context, ref)
                          : null,
                      child: const Icon(Icons.add),
                    )
                  : null,
          floatingActionButtonLocation:
              isCompact && canManageBookings && currentRoute == 'dashboard'
                  ? FloatingActionButtonLocation.endDocked
                  : null,
          bottomNavigationBar: isCompact && bottomItems.isNotEmpty
              ? BottomAppBar(
                  shape: canManageBookings
                      ? const CircularNotchedRectangle()
                      : null,
                  notchMargin: canManageBookings ? 8 : 0,
                  child: SizedBox(
                    height: 64,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        for (final item in bottomItems)
                          Expanded(
                            child: IconButton(
                              tooltip: item.tooltip,
                              onPressed: item.route == 'dashboard'
                                  ? () => router.replaceAllWith('dashboard')
                                  : effectivePropertyId != null
                                      ? () => router.replaceAllWith(item.route)
                                      : null,
                              icon: Icon(
                                currentRoute == item.route
                                    ? item.activeIcon
                                    : item.icon,
                                color: currentRoute == item.route
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey[600],
                              ),
                            ),
                          ),
                        if (canManageBookings) const SizedBox(width: 56),
                      ],
                    ),
                  ),
                )
              : null,
          body: SafeArea(
            top: false,
            child: body,
          ),
        );
      },
    );
  }

  void _showMobileBookingDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New Booking'),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: context.showCompactLayout ? 320 : 720,
            ),
            child: BookingForm(
              onSubmit: (bookingData) async {
                return ref
                    .read(bookingListVM.notifier)
                    .addToBookings(bookingData);
              },
              ref: ref,
            ),
          ),
        );
      },
    );
  }
}

class _DashboardBottomNavItem {
  final String route;
  final IconData icon;
  final IconData activeIcon;
  final String tooltip;

  const _DashboardBottomNavItem({
    required this.route,
    required this.icon,
    required this.activeIcon,
    required this.tooltip,
  });
}

class PublicPageScaffold extends StatelessWidget {
  const PublicPageScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.drawer,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? drawer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      drawer: context.showCompactLayout ? (drawer ?? const DrawerNav()) : null,
      body: SafeArea(
        child: body,
      ),
    );
  }
}
