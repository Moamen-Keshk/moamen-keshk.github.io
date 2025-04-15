import 'package:flutter/material.dart';
import 'package:flutter_academy/app/global/selected_property.global.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_academy/app/courses/view_models/booking.vm.dart';
import 'package:flutter_academy/app/courses/view_models/floor.vm.dart';
import 'package:flutter_academy/infrastructure/courses/model/room.model.dart';
import 'booking_tile.dart';
import 'available_slot.dart';

class BookingWithTab {
  final int tabSize;
  final BookingVM bookingVM;

  BookingWithTab({required this.tabSize, required this.bookingVM});
}

class RoomBookingGrid extends StatelessWidget {
  final List<FloorVM> floors;
  final List<BookingVM> bookings;
  final int numberOfDays;
  final int currentMonth;
  final int currentYear;
  final TabController tabController;
  final WidgetRef ref;
  final bool showRates; // NEW: Toggle flag passed from parent

  const RoomBookingGrid({
    super.key,
    required this.floors,
    required this.bookings,
    required this.numberOfDays,
    required this.currentMonth,
    required this.currentYear,
    required this.tabController,
    required this.ref,
    required this.showRates, // NEW: Required flag
  });

  @override
  Widget build(BuildContext context) {
    int i = 0;

    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            controller: scrollController2,
            scrollDirection: Axis.horizontal,
            child: Column(
              children: floors.map<Padding>((floor) {
                return Padding(
                  padding: const EdgeInsets.only(top: 25),
                  child: Column(
                    children: floor.rooms.map<Row>((Room room) {
                      final bookingsPerRoom = _isRoomHasBooking(
                        bookings,
                        int.parse(room.id),
                      );
                      final tabSizes = _isDayHasBooking(
                        bookingsPerRoom,
                        numberOfDays,
                        currentMonth,
                        currentYear,
                      );
                      final tabPositions = tabSizes.keys.toList();
                      List<Widget> rowChildren = [];
                      int currentDay = 1;

                      while (currentDay <= numberOfDays) {
                        if (tabPositions.contains(currentDay)) {
                          final tabIndex = i;
                          int tabSize = tabSizes[currentDay]?.tabSize ?? 1;
                          if (tabSize + currentDay - 1 > numberOfDays) {
                            tabSize = numberOfDays - currentDay + 1;
                          }
                          rowChildren.add(
                            Flexible(
                              flex: tabSize,
                              fit: FlexFit.loose,
                              child: BookingTile(
                                tabIndex: tabIndex,
                                tabController: tabController,
                                tabSize: tabSize,
                                booking: tabSizes[currentDay]!.bookingVM,
                              ),
                            ),
                          );
                          currentDay += tabSize;
                          i++;
                        } else {
                          rowChildren.add(
                            AvailableSlot(
                              tabDay: currentDay,
                              tabRoom: room.id,
                              ref: ref,
                              date: DateTime(
                                  currentYear, currentMonth, currentDay),
                              showRates: showRates, // NEW: uses toggle
                            ),
                          );
                          currentDay++;
                        }
                      }

                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: rowChildren,
                      );
                    }).toList(),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  List<BookingVM> _isRoomHasBooking(List<BookingVM> bookings, int roomId) {
    return bookings.where((booking) => booking.roomID == roomId).toList();
  }

  Map<int, BookingWithTab> _isDayHasBooking(
    List<BookingVM> bookingPerRoom,
    int numberOfDays,
    int currentMonth,
    int currentYear,
  ) {
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
}
