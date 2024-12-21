import 'package:flutter/material.dart';
import 'package:flutter_academy/app/courses/view_models/booking.vm.dart';
import 'package:flutter_academy/app/courses/view_models/booking_list.vm.dart';
import 'package:flutter_academy/app/courses/view_models/category.vm.dart';
import 'package:flutter_academy/app/courses/view_models/category_list.vm.dart';
import 'package:flutter_academy/app/courses/view_models/floor.vm.dart';
import 'package:flutter_academy/app/courses/view_models/floor_list.vm.dart';
import 'package:flutter_academy/app/courses/view_models/payment_status_list.vm.dart';
import 'package:flutter_academy/app/courses/view_models/room.vm.dart';
import 'package:flutter_academy/app/courses/view_models/room_list.vm.dart';
import 'package:flutter_academy/app/courses/views/edit_booking.view.dart';
import 'package:flutter_academy/app/courses/views/new_booking.view.dart';
import 'package:flutter_academy/app/global/selected_property.global.dart';
import 'package:flutter_academy/infrastructure/courses/model/room.model.dart';
import 'package:flutter_academy/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:month_year_picker/month_year_picker.dart';

DateFormat format = DateFormat('EEE, dd MMMM');

Map<int, int> roomsCategoryMapping = {};

Map<int, String> roomMapping = {};

Map<int, String> categoryMapping = {};

class BookingWithTab {
  final int tabSize;
  final BookingVM bookingVM;
  BookingWithTab({required this.tabSize, required this.bookingVM});
}

class TabBarViewContainer extends StatefulWidget {
  final int tabIndex;
  final TabController tabController;
  final int tabSize;
  final BookingVM booking;

  const TabBarViewContainer({
    super.key,
    required this.tabIndex,
    required this.tabController,
    required this.tabSize,
    required this.booking,
  });

  @override
  State<TabBarViewContainer> createState() => _TabBarViewContainerState();
}

class _TabBarViewContainerState extends State<TabBarViewContainer> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  void toggleAppearance() {
    setState(() {
      _focusNode.requestFocus();
      _isFocused = !_isFocused;
    });
  }

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
          widget.tabController.animateTo(widget.tabIndex);
          _focusNode.requestFocus();
        },
        child: Draggable<BookingVM>(
          data: widget.booking,
          feedback: Material(
            color: Colors.transparent,
            child: Container(
              height: 35,
              width: 93.9 * widget.tabSize,
              decoration: BoxDecoration(
                color: Colors.blue[300],
                borderRadius: BorderRadius.circular(18),
              ),
              child: Center(
                child: Text(
                  "${widget.booking.firstName} ${widget.booking.lastName}",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
          childWhenDragging: Opacity(
            opacity: 0.5,
            child: Container(
              height: 35,
              width: 93.9 * widget.tabSize,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(18),
              ),
              child: Center(
                child: Text(
                  "${widget.booking.firstName} ${widget.booking.lastName}",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
          child: Focus(
              focusNode: _focusNode,
              child: Container(
                height: 35,
                width: 93.9 * widget.tabSize,
                decoration: BoxDecoration(
                  color: _isFocused
                      ? Colors.brown[300]
                      : widget.booking.paymentStatusID == 1
                          ? Colors.blue[300]
                          : Colors.red[300],
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: Text(
                      "${widget.booking.firstName} ${widget.booking.lastName}",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white)),
                ),
              )),
        ));
  }
}

class AvailableTabContainer extends StatelessWidget {
  final int tabDay;
  final String tabRoom;
  final WidgetRef ref;
  const AvailableTabContainer(
      {super.key,
      required this.tabDay,
      required this.tabRoom,
      required this.ref});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          showBookingDialog(context, ref);
        },
        child: MouseRegion(
            onEnter: (_) {
              ref.read(highlightedDayVM.notifier).updateDay(tabDay);
              ref.read(highlightedRoomVM.notifier).updateRoom(
                  int.parse(tabRoom)); // Assuming this is the row number
// Assuming this is the column number
            },
            onExit: (_) {
              ref.read(highlightedDayVM.notifier).updateDay(0);
              ref.read(highlightedRoomVM.notifier).updateRoom(0);
            },
            child: DragTarget<BookingVM>(onWillAcceptWithDetails: (details) {
              // Validate the room category
              return roomsCategoryMapping[details.data.roomID] ==
                  roomsCategoryMapping[int.parse(tabRoom)];
            }, onAcceptWithDetails: (details) async {
              int numberOfNights = details.data.numberOfNights;
              int checkInYear = details.data.checkInYear;
              int checkInMonth = details.data.checkInMonth;
              // Update booking details
              if (await ref
                  .read(bookingListVM.notifier)
                  .editBooking(int.parse(details.data.id), {
                'room_id': tabRoom,
                'chech_in': DateTime(checkInYear, checkInMonth, tabDay)
                    .toIso8601String(),
                'chech_out':
                    DateTime(checkInYear, checkInMonth, tabDay + numberOfNights)
                        .toIso8601String(),
                'check_in_day': tabDay,
                'check_out_day': tabDay + numberOfNights
              })) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Booking edited successfully.')),
                  );
                }
              }
            }, builder: (context, candidateData, rejectedData) {
              return SizedBox(
                height: 35,
                width: 93.9,
                child: Container(
                  color: candidateData.isNotEmpty
                      ? Colors.green[200]
                      : Colors.grey[200],
                  margin: EdgeInsets.all(2),
                ),
              );
            })));
  }

  void showBookingDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('New Booking'),
          content: BookingForm(
              tabDay: tabDay,
              tabRoom: tabRoom,
              onSubmit: (bookingData) async {
                return ref
                    .read(bookingListVM.notifier)
                    .addToBookings(bookingData);
              },
              ref: ref),
        );
      },
    );
  }
}

class FloorRooms extends StatefulWidget {
  const FloorRooms({super.key});

  @override
  State<FloorRooms> createState() => _FloorRoomsState();
}

class _FloorRoomsState extends State<FloorRooms> with TickerProviderStateMixin {
  final ScrollController scrollController1 = ScrollController();
  final ScrollController scrollController2 = ScrollController();
  late TabController _tabController;
  late List<DateTime> _daysInMonth;
  List<BookingVM> bookingsForTabBarView = [];
  late Map<int, String> paymentStatusMapping;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 0, vsync: this, initialIndex: 0);
    scrollController2.addListener(() {
      if (scrollController1.hasClients) {
        scrollController1.jumpTo(scrollController2.offset);
      }
    });
    PaymentStatusListVM().paymentStatusMapping().then((result) {
      paymentStatusMapping = result;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    scrollController1.dispose();
    scrollController2.dispose();
    super.dispose();
  }

  Map<int, int> setRoomCategory(
      List<RoomVM> rooms, List<CategoryVM> categories) {
    Map<int, String> categoriesNaming = {};
    Map<int, String> roomNumbering = {};
    Map<int, int> categoryMap = {};
    for (var category in categories) {
      categoriesNaming[int.parse(category.id)] = category.name;
    }
    for (var room in rooms) {
      categoryMap[int.parse(room.id!)] = room.categoryId;
      roomNumbering[int.parse(room.id!)] = room.roomNumber.toString();
    }
    roomMapping = roomNumbering;
    categoryMapping = categoriesNaming;
    return categoryMap;
  }

  void tabBarControllerLength(List<FloorVM> floors, List<BookingVM> bookings,
      int numberOfDays, int currentMonth, int currentYear) {
    bookingsForTabBarView = [];
    int totalTabs = 0;
    for (var floor in floors) {
      for (var room in floor.rooms) {
        final bookingsPerRoom = isRoomHasBooking(bookings, int.parse(room.id!));
        totalTabs += bookingsPerRoom.length;
        bookingsForTabBarView.addAll(bookingsPerRoom);
      }
    }
    updateTabController(totalTabs);
  }

  void updateTabController(int newLength) {
    if (_tabController.length != newLength) {
      _tabController.dispose(); // Dispose the old controller
      _tabController = TabController(length: newLength, vsync: this);
    }
  }

  List<DateTime> _getDaysInMonth(int year, int month) {
    int daysCount = DateTime(year, month + 1, 0).day;
    return List<DateTime>.generate(
      daysCount,
      (index) => DateTime(year, month, index + 1),
    );
  }

  void _scrollToToday() {
    DateTime today = DateTime.now();
    int todayIndex = _daysInMonth.indexWhere((day) =>
        day.day == today.day &&
        day.month == today.month &&
        day.year == today.year);

    if (todayIndex != -1 && scrollController1.hasClients) {
      double targetScrollOffset =
          todayIndex * 39.9; // Adjust this factor based on item width.
      scrollController2.animateTo(
        targetScrollOffset,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      scrollController1.animateTo(
        targetScrollOffset,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final floors = ref.watch(floorListVM);
      final bookings = ref.watch(bookingListVM);
      final selectedDate = ref.watch(selectedMonthVM);
      final selectedMonth = selectedDate.month;
      final selectedYear = selectedDate.year;
      final numberOfDays = ref.watch(numberOfDaysVM);
      _daysInMonth = _getDaysInMonth(selectedYear, selectedMonth);
      final categories = ref.watch(categoryListVM);
      roomsCategoryMapping = setRoomCategory(ref.read(roomListVM), categories);
      int i = 0;
      tabBarControllerLength(
          floors, bookings, numberOfDays, selectedMonth, selectedYear);
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToToday());
      return Padding(
        padding: EdgeInsets.only(left: 6, right: 4),
        child: Column(
          children: [
            Row(children: [
              Column(children: [
                SizedBox(
                  width: 160,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        shape: BeveledRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    )),
                    onPressed: () async {
                      final localSelectedMonth = ref
                          .read(selectedMonthVM.notifier)
                          .updateMonth((await showMonthYearPicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(20),
                            lastDate: DateTime(2027),
                          ))!);

                      ref.read(numberOfDaysVM.notifier).updateDays(DateTime(
                              localSelectedMonth!.year,
                              localSelectedMonth.month + 1,
                              0)
                          .day);
                    },
                    child: Text(
                      DateFormat('MMMM yyyy').format(selectedDate).toString(),
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Container(
                    alignment: Alignment.center,
                    width: 160,
                    height: 35,
                    padding: EdgeInsets.symmetric(vertical: 7, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('Rooms',
                        style: TextStyle(
                          fontSize: 15,
                        ))),
              ]),
              Expanded(
                  child: Column(children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: SizedBox(
                      height: 70,
                      child: SingleChildScrollView(
                        controller: scrollController1,
                        physics: NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        child: Consumer(builder: (context, ref, child) {
                          final int highlightedDay =
                              ref.watch(highlightedDayVM);
                          return Row(
                              children:
                                  _daysInMonth.map<Padding>((DateTime dayIn) {
                            DateTime day = dayIn;
                            DateTime today = DateTime.now();
                            bool isToday = day.day == today.day &&
                                day.month == today.month &&
                                day.year == today.year;
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 26.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    DateFormat.E().format(
                                        day), // Short weekday name (e.g., Mon, Tue)
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    height: 42,
                                    width: 42,
                                    decoration: BoxDecoration(
                                      color: isToday
                                          ? Colors.blue
                                          : (day.day == highlightedDay)
                                              ? Colors.green[200]
                                              : Colors.grey[200],
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(12),
                                    child: Center(
                                        child: Text(
                                      '${day.day}',
                                      style: TextStyle(
                                        color: isToday
                                            ? Colors.white
                                            : Colors.black,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    )),
                                  ),
                                ],
                              ),
                            );
                          }).toList());
                        }),
                      )),
                ),
              ]))
            ]),
            SizedBox(
                height: 530,
                child: SingleChildScrollView(
                  physics: ClampingScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  child: Row(
                    children: [
                      Consumer(builder: (context, ref, child) {
                        final int highlightedRoom =
                            ref.watch(highlightedRoomVM);
                        return Column(
                          children: floors.map<Column>((FloorVM floor) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 100,
                                  height: 25,
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.symmetric(
                                      vertical: 4, horizontal: 20),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[300],
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    'Floor ${floor.number.toString()}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children:
                                      floor.rooms.map<Container>((Room room) {
                                    return Container(
                                      alignment: Alignment.center,
                                      width: 160,
                                      height: 35,
                                      padding: EdgeInsets.symmetric(
                                          vertical: 7, horizontal: 20),
                                      decoration: BoxDecoration(
                                        color: (int.parse(room.id!) ==
                                                highlightedRoom)
                                            ? Colors.green[200]
                                            : Colors.orange[100],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'Room ${room.roomNumber.toString()}',
                                        style: TextStyle(
                                          fontSize: 15,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            );
                          }).toList(),
                        );
                      }),
                      Expanded(
                          child: SingleChildScrollView(
                              controller: scrollController2,
                              physics: ClampingScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              child: Row(children: [
                                Column(
                                  children:
                                      floors.map<Padding>((FloorVM floor) {
                                    return Padding(
                                      padding: EdgeInsets.only(top: 25),
                                      child: Column(
                                        children:
                                            floor.rooms.map<Row>((Room room) {
                                          final bookingsPerRoom =
                                              isRoomHasBooking(bookings,
                                                  int.parse(room.id!));
                                          final tabSizes = isDayHasBooking(
                                              bookingsPerRoom,
                                              numberOfDays,
                                              selectedMonth,
                                              selectedYear);
                                          final tabPositions =
                                              tabSizes.keys.toList();
                                          return Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: () {
                                              List<Widget> rowChildren = [];
                                              int currentDay = 1;
                                              while (
                                                  currentDay <= numberOfDays) {
                                                if (tabPositions
                                                    .contains(currentDay)) {
                                                  final tabIndex = i;
                                                  int tabSize =
                                                      tabSizes[currentDay]
                                                              ?.tabSize ??
                                                          1;

                                                  // Handle case where tabSize spans beyond the end of the current month
                                                  if (tabSize + currentDay - 1 >
                                                      numberOfDays) {
                                                    tabSize = numberOfDays -
                                                        currentDay +
                                                        1; // Adjust to fit remaining days
                                                  }
                                                  rowChildren.add(
                                                    Flexible(
                                                      flex: tabSize,
                                                      fit: FlexFit.loose,
                                                      child:
                                                          TabBarViewContainer(
                                                        tabIndex: tabIndex,
                                                        tabController:
                                                            _tabController,
                                                        tabSize: tabSize,
                                                        booking: tabSizes[
                                                                currentDay]!
                                                            .bookingVM,
                                                      ),
                                                    ),
                                                  );
                                                  currentDay +=
                                                      tabSize; // Skip days covered by this booking
                                                  i++;
                                                } else {
                                                  // No booking on this day; add a blank slot
                                                  rowChildren.add(
                                                    AvailableTabContainer(
                                                        tabDay: currentDay,
                                                        tabRoom: room.id!,
                                                        ref: ref),
                                                  );
                                                  currentDay++;
                                                }
                                              }
                                              return rowChildren;
                                            }(),
                                          );
                                        }).toList(),
                                      ),
                                    );
                                  }).toList(),
                                )
                              ]))),
                    ],
                  ),
                )),
            SizedBox(
              height: 80,
              child: Padding(
                  padding: EdgeInsets.all(4),
                  child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TabBarView(
                        controller: _tabController,
                        physics: NeverScrollableScrollPhysics(),
                        children: bookingsForTabBarView.map((bookingWithTab) {
                          return Padding(
                              padding: EdgeInsets.all(8),
                              child: Center(
                                  child: Row(children: [
                                Expanded(
                                    child: Column(children: [
                                  Row(children: [
                                    Expanded(
                                        child: Text(
                                      '${bookingWithTab.firstName} ${bookingWithTab.lastName}',
                                      style: TextStyle(fontSize: 14),
                                    )),
                                    Expanded(
                                        child: Text(
                                      '${bookingWithTab.numberOfNights} nights',
                                      style: TextStyle(fontSize: 14),
                                    )),
                                    Expanded(
                                        child: Text(
                                      'Room: ${roomMapping[bookingWithTab.roomID]}',
                                      style: TextStyle(fontSize: 14),
                                    )),
                                    Expanded(
                                        flex: 2,
                                        child: Text(
                                          '(${format.format(bookingWithTab.checkIn)}) to (${format.format(bookingWithTab.checkOut)})',
                                          style: TextStyle(fontSize: 14),
                                        )),
                                    Expanded(
                                        child: Text(
                                      'Adults: ${bookingWithTab.numberOfAdults}',
                                      style: TextStyle(fontSize: 14),
                                    )),
                                    Expanded(
                                        child: Text(
                                      'Children: ${bookingWithTab.numberOfChildren}',
                                      style: TextStyle(fontSize: 14),
                                    )),
                                  ]),
                                  SizedBox(height: 10),
                                  Row(children: [
                                    SizedBox(
                                        width: 130,
                                        child: Text(
                                          '${paymentStatusMapping[bookingWithTab.paymentStatusID]}',
                                          style: TextStyle(fontSize: 14),
                                        )),
                                    Expanded(
                                        child: Text(
                                      'Category: ${categoryMapping[roomsCategoryMapping[bookingWithTab.roomID]]}',
                                      style: TextStyle(fontSize: 14),
                                    )),
                                    Expanded(
                                        child: Text(
                                      'created: ${format.format(bookingWithTab.bookingDate)}',
                                      style: TextStyle(fontSize: 14),
                                    )),
                                    Expanded(
                                        child: Text(
                                      'price: ${bookingWithTab.rate}',
                                      style: TextStyle(fontSize: 14),
                                    )),
                                    Expanded(
                                        flex: 2,
                                        child: Text(
                                          'note: ${bookingWithTab.note}',
                                          style: TextStyle(fontSize: 14),
                                        ))
                                  ])
                                ])),
                                IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () {
                                      showEditBookingDialog(
                                          context, bookingWithTab, ref);
                                      routerDelegate.go('/');
                                    })
                              ])));
                        }).toList(),
                      ))),
            ),
          ],
        ),
      );
    });
  }

  List<BookingVM> isRoomHasBooking(List<BookingVM> bookings, int roomId) {
    return bookings.where((booking) => booking.roomID == roomId).toList();
  }

  Map<int, BookingWithTab> isDayHasBooking(List<BookingVM> bookingPerRoom,
      int numberOfDays, int currentMonth, int currentYear) {
    Map<int, BookingWithTab> bookingsMap = {};
    for (BookingVM booking in bookingPerRoom) {
      int checkInDay = booking.checkInDay;
      int numberOfNights = booking.numberOfNights;
      if (booking.checkInMonth != currentMonth &&
          booking.checkOutMonth == currentMonth) {
        checkInDay = 1;
        numberOfNights =
            numberOfNights - (booking.checkIn.day - booking.checkInDay + 1);
      } else if (booking.checkInMonth == currentMonth &&
          booking.checkOutMonth != currentMonth) {
        numberOfNights = numberOfDays - checkInDay + 1;
      }
      // Adjust check-out day if it spills into the next month
      if (booking.checkOutYear == currentYear ||
          (booking.checkOutYear != currentYear &&
              booking.checkInMonth == currentMonth)) {
        bookingsMap[checkInDay] =
            BookingWithTab(tabSize: numberOfNights, bookingVM: booking);
      }
    }
    return Map.fromEntries(
      bookingsMap.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
  }

  void showEditBookingDialog(
      BuildContext context, BookingVM booking, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Booking'),
          content: EditBookingForm(
              booking: booking,
              onSubmit: (bookingData) {
                return ref
                    .read(bookingListVM.notifier)
                    .editBooking(int.parse(booking.id), bookingData);
              },
              ref: ref),
        );
      },
    );
  }
}
