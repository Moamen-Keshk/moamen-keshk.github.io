import 'package:flutter/material.dart';
import 'package:lotel_pms/app/api/res/responsive.res.dart';
import 'package:lotel_pms/app/api/view_models/lists/booking_list.vm.dart';
import 'package:lotel_pms/app/api/views/new_booking.view.dart';
import 'package:lotel_pms/app/api/widgets/dashboard_drawer.widget.dart';
import 'package:lotel_pms/app/api/widgets/dashboard_nav.widget.dart';
import 'package:lotel_pms/app/api/widgets/hotel_calendar.widget.dart';
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

class CompactViewHeader extends StatelessWidget {
  const CompactViewHeader({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    if (!context.showCompactLayout) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Divider(
            height: 1,
            thickness: 1,
            color: Colors.grey.shade300,
          ),
        ],
      ),
    );
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
        final canViewRates = hasPmsPermission(ref, PmsPermission.viewRates);
        final canUpdateRoomStatus =
            hasPmsPermission(ref, PmsPermission.updateRoomStatus);
        final effectivePropertyId = ref.watch(effectivePropertyIdProvider);
        final showRates = ref.watch(dashboardShowRatesProvider);
        final showDashboardActions = isCompact && currentRoute == 'dashboard';

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
          drawer: null,
          floatingActionButton: showDashboardActions &&
                  (canManageBookings || canViewRates)
              ? Transform.translate(
                  offset: const Offset(0, 18),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (canViewRates)
                        FloatingActionButton.small(
                          heroTag: 'dashboard-rates-toggle-fab',
                          tooltip: showRates ? 'Hide Rates' : 'Show Rates',
                          backgroundColor:
                              showRates ? Colors.green[200] : Colors.grey[300],
                          foregroundColor: Colors.black,
                          onPressed: () {
                            ref
                                    .read(dashboardShowRatesProvider.notifier)
                                    .state =
                                !showRates;
                          },
                          child: const Icon(Icons.sell_outlined, size: 18),
                        ),
                      if (canViewRates && canManageBookings)
                        const SizedBox(height: 8),
                      if (canManageBookings)
                        FloatingActionButton.small(
                          heroTag: 'dashboard-new-booking-fab',
                          tooltip: 'New Booking',
                          onPressed: effectivePropertyId != null
                              ? () => _showMobileBookingDialog(context, ref)
                              : null,
                          child: const Icon(Icons.add, size: 18),
                        ),
                    ],
                  ),
                )
                )
              : null,
          floatingActionButtonLocation:
              showDashboardActions && (canManageBookings || canViewRates)
                  ? FloatingActionButtonLocation.endFloat
                  : null,
          bottomNavigationBar: isCompact && bottomItems.isNotEmpty
              ? SafeArea(
                  top: false,
                  child: Container(
                    height: 50,
                    margin: const EdgeInsets.fromLTRB(6, 0, 6, 4),
                    padding: EdgeInsets.zero,
                    color: Colors.transparent,
                    child: Row(
                      children: [
                        for (final item in bottomItems)
                          Expanded(
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 48,
                                minHeight: 48,
                              ),
                              visualDensity: const VisualDensity(
                                horizontal: 0,
                                vertical: -3,
                              ),
                              tooltip: isCompact ? null : item.tooltip,
                              onPressed: item.route == 'dashboard'
                                  ? () => router.replaceAllWith('dashboard')
                                  : effectivePropertyId != null
                                      ? () => router.replaceAllWith(item.route)
                                      : null,
                              icon: Icon(
                                currentRoute == item.route
                                    ? item.activeIcon
                                    : item.icon,
                                size: 22,
                                color: currentRoute == item.route
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey[600],
                              ),
                            ),
                          ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 48,
                            minHeight: 48,
                          ),
                          visualDensity: const VisualDensity(
                            horizontal: 0,
                            vertical: -3,
                          ),
                          tooltip: null,
                          onPressed: () => _showDashboardMenuSheet(context),
                          icon: const Icon(Icons.menu, size: 22),
                        ),
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
  Future<void> _showDashboardMenuSheet(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FractionallySizedBox(
        heightFactor: 0.82,
        child: DashboardMenuPanel(asSheet: true),
      ),
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
