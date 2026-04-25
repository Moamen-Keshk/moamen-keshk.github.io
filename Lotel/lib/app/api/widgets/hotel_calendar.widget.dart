import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lotel_pms/app/api/res/responsive.res.dart';
import 'package:lotel_pms/app/api/view_models/booking.vm.dart';
import 'package:lotel_pms/app/api/view_models/category.vm.dart';
import 'package:lotel_pms/app/api/view_models/floor.vm.dart';
import 'package:lotel_pms/app/api/view_models/lists/booking_list.vm.dart';
import 'package:lotel_pms/app/api/view_models/lists/block_list.vm.dart';
import 'package:lotel_pms/app/api/view_models/lists/category_list.vm.dart';
import 'package:lotel_pms/app/api/view_models/lists/floor_list.vm.dart';
import 'package:lotel_pms/app/api/view_models/lists/payment_status_list.vm.dart';
import 'package:lotel_pms/app/api/view_models/lists/room_list.vm.dart';
import 'package:lotel_pms/app/api/view_models/lists/room_online_list.vm.dart';
import 'package:lotel_pms/app/api/view_models/room.vm.dart';
import 'package:lotel_pms/app/global/selected_property.global.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart' show StateProvider;
import 'package:intl/intl.dart';
import 'package:month_year_picker/month_year_picker.dart';

import 'calendar_header.dart';
import 'room_label_column.dart';
import 'room_booking_grid.dart';
import 'booking_details_bar.dart';

final dashboardShowRatesProvider = StateProvider<bool>((ref) => false);

class FloorRooms extends ConsumerStatefulWidget {
  const FloorRooms({super.key});

  @override
  ConsumerState<FloorRooms> createState() => _FloorRoomsState();
}

class _FloorRoomsState extends ConsumerState<FloorRooms>
    with TickerProviderStateMixin {
  final ScrollController _calendarScrollController = ScrollController();
  final ScrollController _gridScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  late TabController _tabController;
  late List<DateTime> _daysInMonth;
  List<BookingVM> bookingsForTabBarView = [];
  final Map<int, String> paymentStatusMapping = {};
  Map<int, String> roomMapping = {};
  Map<int, String> categoryMapping = {};
  bool _hasScrolledToToday = false;
  bool _isSyncing = false;
  String? _lastAutoRefreshKey;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 0, vsync: this);

    _calendarScrollController.addListener(() {
      if (_isSyncing) return;
      _isSyncing = true;
      _gridScrollController.jumpTo(_calendarScrollController.offset);
      _isSyncing = false;
    });

    _gridScrollController.addListener(() {
      if (_isSyncing) return;
      _isSyncing = true;
      _calendarScrollController.jumpTo(_gridScrollController.offset);
      _isSyncing = false;
    });

    PaymentStatusListVM().paymentStatusMapping().then((result) {
      if (mounted) {
        setState(() => paymentStatusMapping.addAll(result));
      }
    });
  }

  void _scrollToToday() {
    final today = DateTime.now();
    final todayIndex = _daysInMonth.indexWhere((day) =>
        day.day == today.day &&
        day.month == today.month &&
        day.year == today.year);

    if (!mounted || todayIndex == -1) return;

    final double dateCellWidth = context.showCompactLayout
        ? CalendarHeader.compactDayColumnWidth
        : CalendarHeader.regularDayColumnWidth;
    final offset = todayIndex * dateCellWidth;

    try {
      _calendarScrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } catch (e, st) {
      debugPrint('>>> [_scrollToToday] EXCEPTION: $e\n$st');
    }
  }

  @override
  void dispose() {
    _calendarScrollController.dispose();
    _gridScrollController.dispose();
    _verticalScrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Map<int, int> setRoomCategory(
      List<RoomVM> rooms, List<CategoryVM> categories) {
    categoryMapping = {
      for (var category in categories) int.parse(category.id): category.name
    };

    roomMapping = {
      for (var room in rooms)
        if (room.id case var id when int.tryParse(id) != null)
          int.parse(id): room.roomNumber.toString()
    };

    final categoryMap = {
      for (var room in rooms) int.tryParse(room.id) ?? 0: room.categoryId,
    };

    return categoryMap;
  }

  List<DateTime> _getDaysInMonth(int year, int month) {
    final daysCount = DateTime(year, month + 1, 0).day;
    return List.generate(daysCount, (i) => DateTime(year, month, i + 1));
  }

  void _prepareTabController(List<FloorVM> floors, List<BookingVM> bookings) {
    bookingsForTabBarView.clear();
    int totalTabs = 0;
    for (var floor in floors) {
      for (var room in floor.rooms) {
        final bookingsPerRoom =
            bookings.where((b) => b.roomID == int.tryParse(room.id)).toList();
        totalTabs += bookingsPerRoom.length;
        bookingsForTabBarView.addAll(bookingsPerRoom);
      }
    }

    if (_tabController.length != totalTabs) {
      _tabController.dispose();
      _tabController = TabController(length: totalTabs, vsync: this);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final isCompact = context.showCompactLayout;
      final showRates = ref.watch(dashboardShowRatesProvider);
      final floors = ref.watch(floorListVM);
      final bookings = ref.watch(bookingListVM);
      final blocks = ref.watch(blockListVM); // 👈 watch blocks
      final selectedDate = ref.watch(selectedMonthVM);
      final numberOfDays = ref.watch(numberOfDaysVM);
      final categories = ref.watch(categoryListVM);
      final rooms = ref.watch(roomListVM);

      final selectedMonth = selectedDate.month;
      final selectedYear = selectedDate.year;
      final selectedPropertyId = ref.watch(selectedPropertyVM);

      _daysInMonth = _getDaysInMonth(selectedYear, selectedMonth);
      final roomsCategoryMapping = setRoomCategory(rooms, categories);

      _prepareTabController(floors, bookings);

      if (!_hasScrolledToToday && _daysInMonth.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _scrollToToday();
            _hasScrolledToToday = true;
          }
        });
      }

      final autoRefreshKey =
          '${selectedPropertyId ?? 0}-$selectedYear-$selectedMonth';
      if (selectedPropertyId != null &&
          selectedPropertyId != 0 &&
          _lastAutoRefreshKey != autoRefreshKey) {
        _lastAutoRefreshKey = autoRefreshKey;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          unawaited(_autoRefreshDashboardData(ref));
        });
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(
          children: [
            // Date Picker + Show Rates + Calendar Header
            isCompact
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: SizedBox(
                              width: RoomLabelColumn.compactRoomLabelWidth,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: double.infinity,
                                    child: _monthButton(
                                        context, ref, selectedDate),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: SizedBox(
                              height: 60,
                              child: CalendarHeader(
                                daysInMonth: _daysInMonth,
                                scrollController: _calendarScrollController,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: RoomLabelColumn.regularRoomLabelWidth,
                              child: _monthButton(context, ref, selectedDate),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: CalendarHeader(
                          daysInMonth: _daysInMonth,
                          scrollController: _calendarScrollController,
                        ),
                      ),
                    ],
                  ),
            const SizedBox(height: 12),
            Expanded(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    controller: _verticalScrollController,
                    scrollDirection: Axis.vertical,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RoomLabelColumn(
                          floors: floors,
                          roomsCategoryMapping: roomsCategoryMapping,
                          categoryMapping: categoryMapping,
                        ),
                        Expanded(
                          child: RoomBookingGrid(
                            floors: floors,
                            bookings: bookings,
                            blocks: blocks, // 👈 pass blocks here
                            numberOfDays: numberOfDays,
                            currentMonth: selectedMonth,
                            currentYear: selectedYear,
                            tabController: _tabController,
                            showRates: showRates,
                            horizontalScrollController: _gridScrollController,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: BookingDetailsBar(
                      bookings: bookingsForTabBarView,
                      roomMapping: roomMapping,
                      roomsCategoryMapping: roomsCategoryMapping,
                      categoryMapping: categoryMapping,
                      paymentStatusMapping: paymentStatusMapping,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Future<void> _autoRefreshDashboardData(WidgetRef ref) async {
    await ref.read(roomOnlineListVM.notifier).fetchRoomOnline();
    await ref.read(blockListVM.notifier).fetchBlocks();
  }

  Widget _monthButton(
    BuildContext context,
    WidgetRef ref,
    DateTime selectedDate,
  ) {
    final firstMonth = DateTime(2020, 1);
    final lastMonth = DateTime(2027, 12);
    final canGoPrevious = !selectedDate.isBefore(firstMonth) &&
        DateTime(selectedDate.year, selectedDate.month) != firstMonth;
    final canGoNext = !selectedDate.isAfter(lastMonth) &&
        DateTime(selectedDate.year, selectedDate.month) != lastMonth;

    Future<void> pickMonth() async {
      final picked = await showMonthYearPicker(
        context: context,
        initialDate: selectedDate,
        firstDate: firstMonth,
        lastDate: lastMonth,
      );
      if (picked != null) {
        ref.read(selectedMonthVM.notifier).updateMonth(picked);
      }
    }

    final monthLabel = DateFormat('MMMM').format(selectedDate);
    final yearLabel = DateFormat('yyyy').format(selectedDate);

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFFF6F1E8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFD8C7AD),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _monthArrowButton(
            icon: Icons.chevron_left_rounded,
            enabled: canGoPrevious,
            onPressed: () {
              final previousMonth =
                  DateTime(selectedDate.year, selectedDate.month - 1);
              ref.read(selectedMonthVM.notifier).updateMonth(previousMonth);
            },
          ),
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: pickMonth,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 6,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            monthLabel,
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF3E3022),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        yearLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                          color: Color(0xFF7A6754),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          _monthArrowButton(
            icon: Icons.chevron_right_rounded,
            enabled: canGoNext,
            onPressed: () {
              final nextMonth =
                  DateTime(selectedDate.year, selectedDate.month + 1);
              ref.read(selectedMonthVM.notifier).updateMonth(nextMonth);
            },
          ),
        ],
      ),
    );
  }

  Widget _monthArrowButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 30,
      height: double.infinity,
      child: IconButton(
        padding: EdgeInsets.zero,
        visualDensity: const VisualDensity(horizontal: -3, vertical: -3),
        onPressed: enabled ? onPressed : null,
        icon: Icon(icon, size: 20),
        color: const Color(0xFF6D5640),
        disabledColor: const Color(0xFFCBBCA6),
      ),
    );
  }

}
