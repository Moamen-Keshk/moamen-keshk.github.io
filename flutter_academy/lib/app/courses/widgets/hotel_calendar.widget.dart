import 'package:flutter/material.dart';
import 'package:flutter_academy/app/courses/view_models/booking.vm.dart';
import 'package:flutter_academy/app/courses/view_models/category.vm.dart';
import 'package:flutter_academy/app/courses/view_models/floor.vm.dart';
import 'package:flutter_academy/app/courses/view_models/lists/booking_list.vm.dart';
import 'package:flutter_academy/app/courses/view_models/lists/block_list.vm.dart';
import 'package:flutter_academy/app/courses/view_models/lists/category_list.vm.dart';
import 'package:flutter_academy/app/courses/view_models/lists/floor_list.vm.dart';
import 'package:flutter_academy/app/courses/view_models/lists/payment_status_list.vm.dart';
import 'package:flutter_academy/app/courses/view_models/lists/room_list.vm.dart';
import 'package:flutter_academy/app/courses/view_models/lists/room_online_list.vm.dart';
import 'package:flutter_academy/app/courses/view_models/room.vm.dart';
import 'package:flutter_academy/app/global/selected_property.global.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:month_year_picker/month_year_picker.dart';

import '../widgets/calendar_header.dart';
import '../widgets/room_label_column.dart';
import '../widgets/room_booking_grid.dart';
import '../widgets/booking_details_bar.dart';

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
  bool _showRates = false;
  bool _hasScrolledToToday = false;
  bool _isSyncing = false;

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

    const double dateCellWidth = 39.9;
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
      final floors = ref.watch(floorListVM);
      final bookings = ref.watch(bookingListVM);
      final blocks = ref.watch(blockListVM); // 👈 watch blocks
      final selectedDate = ref.watch(selectedMonthVM);
      final numberOfDays = ref.watch(numberOfDaysVM);
      final categories = ref.read(categoryListVM);
      final rooms = ref.read(roomListVM);

      final selectedMonth = selectedDate.month;
      final selectedYear = selectedDate.year;

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

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(
          children: [
            // Date Picker + Show Rates + Calendar Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 140,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: BeveledRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          minimumSize: const Size(140, 36),
                        ),
                        onPressed: () async {
                          final picked = await showMonthYearPicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2027),
                          );
                          if (picked != null) {
                            ref
                                .read(selectedMonthVM.notifier)
                                .updateMonth(picked);
                            ref.read(numberOfDaysVM.notifier).updateDays(
                                  DateTime(picked.year, picked.month + 1, 0)
                                      .day,
                                );
                          }
                        },
                        child: Text(
                          DateFormat('MMMM yyyy').format(selectedDate),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 140,
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _showRates
                                    ? Colors.green[200]
                                    : Colors.grey[300],
                                elevation: 0,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                shape: BeveledRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              onPressed: () {
                                setState(() => _showRates = !_showRates);
                              },
                              child: Text(
                                _showRates ? 'Hide' : 'Rates',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[200],
                                elevation: 0,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                shape: BeveledRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              onPressed: () async {
                                final propertyId = ref.read(selectedPropertyVM);
                                if (propertyId == null) return;

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Refreshing rates...')),
                                );

                                await ref
                                    .read(roomOnlineListVM.notifier)
                                    .fetchRoomOnline();
                                await ref
                                    .read(blockListVM.notifier)
                                    .fetchBlocks(); // 👈 refresh blocks
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Rates updated.')),
                                  );
                                }
                              },
                              child: const Icon(Icons.sync,
                                  size: 16, color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CalendarHeader(
                    daysInMonth: _daysInMonth,
                    scrollController: _calendarScrollController,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: MediaQuery.of(context).size.height - 218,
              child: SingleChildScrollView(
                controller: _verticalScrollController,
                scrollDirection: Axis.vertical,
                child: Row(
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
                        ref: ref,
                        showRates: _showRates,
                        horizontalScrollController: _gridScrollController,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            BookingDetailsBar(
              bookings: bookingsForTabBarView,
              roomMapping: roomMapping,
              roomsCategoryMapping: roomsCategoryMapping,
              categoryMapping: categoryMapping,
              paymentStatusMapping: paymentStatusMapping,
            ),
          ],
        ),
      );
    });
  }
}
