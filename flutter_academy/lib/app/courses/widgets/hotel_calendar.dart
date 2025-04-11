import 'package:flutter/material.dart';
import 'package:flutter_academy/app/courses/utilities/booking_helpers.dart';
import 'package:flutter_academy/app/courses/view_models/booking.vm.dart';
import 'package:flutter_academy/app/courses/view_models/floor.vm.dart';
import 'package:flutter_academy/app/courses/view_models/payment_status_list.vm.dart';
import 'package:flutter_academy/app/global/selected_property.global.dart';
import 'package:flutter_academy/app/courses/view_models/booking_list.vm.dart';
import 'package:flutter_academy/app/courses/view_models/category_list.vm.dart';
import 'package:flutter_academy/app/courses/view_models/floor_list.vm.dart';
import 'package:flutter_academy/app/courses/view_models/room_list.vm.dart';
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
  final ScrollController scrollController1 = ScrollController();
  final ScrollController scrollController2 = ScrollController();
  late TabController _tabController;
  late List<DateTime> _daysInMonth;
  List<BookingVM> bookingsForTabBarView = [];
  final Map<int, String> paymentStatusMapping = {};
  final Map<int, String> roomMapping = {};
  final Map<int, String> categoryMapping = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 0, vsync: this);
    scrollController2.addListener(() {
      if (scrollController1.hasClients) {
        scrollController1.jumpTo(scrollController2.offset);
      }
    });
    PaymentStatusListVM().paymentStatusMapping().then((result) {
      setState(() => paymentStatusMapping.addAll(result));
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    scrollController1.dispose();
    scrollController2.dispose();
    super.dispose();
  }

  List<DateTime> _getDaysInMonth(int year, int month) {
    int daysCount = DateTime(year, month + 1, 0).day;
    return List<DateTime>.generate(
      daysCount,
      (index) => DateTime(year, month, index + 1),
    );
  }

  void _scrollToToday() {
    final today = DateTime.now();
    final todayIndex = _daysInMonth.indexWhere((day) =>
        day.day == today.day &&
        day.month == today.month &&
        day.year == today.year);

    if (todayIndex != -1 && scrollController1.hasClients) {
      final targetOffset = todayIndex * 39.9;
      scrollController1.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      scrollController2.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
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
      final selectedDate = ref.watch(selectedMonthVM);
      final numberOfDays = ref.watch(numberOfDaysVM);
      final categories = ref.read(categoryListVM);
      final rooms = ref.read(roomListVM);

      final selectedMonth = selectedDate.month;
      final selectedYear = selectedDate.year;

      _daysInMonth = _getDaysInMonth(selectedYear, selectedMonth);
      final roomsCategoryMapping = setRoomCategory(
        rooms,
        categories,
        categoryMapping,
        roomMapping,
      );

      _prepareTabController(floors, bookings);

      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToToday());

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(
          children: [
            Row(
              children: [
                Column(
                  children: [
                    SizedBox(
                      width: 160,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: BeveledRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        onPressed: () async {
                          final picked = await showMonthYearPicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2027),
                          );
                          if (picked != null) {
                            ref
                                .read(selectedMonthVM.notifier)
                                .updateMonth(picked);
                            ref.read(numberOfDaysVM.notifier).updateDays(
                                DateTime(picked.year, picked.month + 1, 0).day);
                          }
                        },
                        child: Text(
                          DateFormat('MMMM yyyy').format(selectedDate),
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      alignment: Alignment.center,
                      width: 160,
                      height: 35,
                      decoration: BoxDecoration(
                        color: Colors.orange[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child:
                          const Text('Rooms', style: TextStyle(fontSize: 15)),
                    ),
                  ],
                ),
                Expanded(child: CalendarHeader(daysInMonth: _daysInMonth))
              ],
            ),
            SizedBox(
              height: 530,
              child: SingleChildScrollView(
                controller: scrollController2,
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
                        numberOfDays: numberOfDays,
                        currentMonth: selectedMonth,
                        currentYear: selectedYear,
                        tabController: _tabController,
                        ref: ref,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            BookingDetailsBar(
              bookings: bookingsForTabBarView,
              tabController: _tabController,
              roomMapping: roomMapping,
              roomsCategoryMapping: roomsCategoryMapping,
              categoryMapping: categoryMapping,
              paymentStatusMapping: paymentStatusMapping,
              ref: ref,
            )
          ],
        ),
      );
    });
  }
}
