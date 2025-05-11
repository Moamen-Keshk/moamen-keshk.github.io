import 'package:flutter/material.dart';
import 'package:flutter_academy/app/courses/view_models/lists/booking_list.vm.dart';
import 'package:flutter_academy/app/courses/widgets/block_tile.widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_academy/app/courses/view_models/booking.vm.dart';
import 'package:flutter_academy/app/courses/view_models/block.vm.dart';
import 'package:flutter_academy/app/courses/view_models/floor.vm.dart';
import 'package:flutter_academy/infrastructure/courses/model/room.model.dart';
import 'booking_tile.dart';
import 'available_slot.dart';

class BookingWithTab {
  final int tabSize;
  final BookingVM bookingVM;

  BookingWithTab({required this.tabSize, required this.bookingVM});
}

class BlockWithTab {
  final int tabSize;
  final BlockVM blockVM;

  BlockWithTab({required this.tabSize, required this.blockVM});
}

class RoomBookingGrid extends ConsumerWidget {
  final List<FloorVM> floors;
  final List<BookingVM> bookings;
  final List<BlockVM> blocks;
  final int numberOfDays;
  final int currentMonth;
  final int currentYear;
  final TabController tabController;
  final WidgetRef ref;
  final bool showRates;
  final ScrollController horizontalScrollController;

  const RoomBookingGrid({
    super.key,
    required this.floors,
    required this.bookings,
    required this.blocks,
    required this.numberOfDays,
    required this.currentMonth,
    required this.currentYear,
    required this.tabController,
    required this.ref,
    required this.showRates,
    required this.horizontalScrollController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int tabIndexCounter = 0;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => ref.read(selectedBookingIdProvider.notifier).state = null,
      child: SingleChildScrollView(
        controller: horizontalScrollController,
        scrollDirection: Axis.horizontal,
        child: Column(
          children: floors.map<Padding>((floor) {
            return Padding(
              padding: const EdgeInsets.only(top: 25),
              child: Column(
                children: floor.rooms.map<Row>((Room room) {
                  final bookingsPerRoom = bookings
                      .where((b) => b.roomID == int.tryParse(room.id))
                      .toList();

                  final blocksPerRoom = blocks
                      .where((b) => b.roomID == int.tryParse(room.id))
                      .toList();

                  final bookingsTabSizes = _buildBookingTabSizeMap(
                    bookingsPerRoom,
                    numberOfDays,
                    currentMonth,
                    currentYear,
                  );

                  final blocksTabSizes = _buildBlockTabSizeMap(
                    blocksPerRoom,
                    numberOfDays,
                    currentMonth,
                    currentYear,
                  );

                  List<Widget> rowChildren = [];
                  int currentDay = 1;

                  while (currentDay <= numberOfDays) {
                    if (bookingsTabSizes.containsKey(currentDay)) {
                      final tabSize = bookingsTabSizes[currentDay]!.tabSize;
                      rowChildren.add(
                        Flexible(
                          flex: tabSize,
                          fit: FlexFit.loose,
                          child: BookingTile(
                            tabIndex: tabIndexCounter,
                            tabController: tabController,
                            tabSize: tabSize,
                            booking: bookingsTabSizes[currentDay]!.bookingVM,
                          ),
                        ),
                      );
                      currentDay += tabSize;
                      tabIndexCounter++;
                    } else if (blocksTabSizes.containsKey(currentDay)) {
                      final tabSize = blocksTabSizes[currentDay]!.tabSize;
                      rowChildren.add(
                        Flexible(
                          flex: tabSize,
                          fit: FlexFit.loose,
                          child: BlockTile(
                            tabIndex: tabIndexCounter,
                            tabController: tabController,
                            tabSize: tabSize,
                            block: blocksTabSizes[currentDay]!.blockVM,
                          ),
                        ),
                      );
                      currentDay += tabSize;
                      tabIndexCounter++;
                    } else {
                      rowChildren.add(
                        AvailableSlot(
                          tabDay: currentDay,
                          tabRoom: room.id,
                          date: DateTime(currentYear, currentMonth, currentDay),
                          showRates: showRates,
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
    );
  }

  Map<int, BookingWithTab> _buildBookingTabSizeMap(
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
        numberOfNights = booking.numberOfNights -
            (booking.checkIn.day - booking.checkInDay + 1);
      } else if (booking.checkInMonth == currentMonth &&
          booking.checkOutMonth != currentMonth) {
        numberOfNights = numberOfDays - checkInDay + 1;
      }

      if (booking.checkOutYear == currentYear ||
          (booking.checkOutYear != currentYear &&
              booking.checkInMonth == currentMonth)) {
        bookingsMap[checkInDay] = BookingWithTab(
          tabSize: numberOfNights,
          bookingVM: booking,
        );
      }
    }

    return Map.fromEntries(
      bookingsMap.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
  }

  Map<int, BlockWithTab> _buildBlockTabSizeMap(
    List<BlockVM> blocksPerRoom,
    int numberOfDays,
    int currentMonth,
    int currentYear,
  ) {
    Map<int, BlockWithTab> blocksMap = {};

    for (BlockVM block in blocksPerRoom) {
      int startDay = block.startDay;
      int daysInBlock = block.numberOfDays;

      if (block.startMonth != currentMonth && block.endMonth == currentMonth) {
        startDay = 1;
        daysInBlock = block.endDate
                .difference(DateTime(currentYear, currentMonth, 1))
                .inDays +
            1;
      } else if (block.startMonth == currentMonth &&
          block.endMonth != currentMonth) {
        daysInBlock = numberOfDays - startDay + 1;
      }

      blocksMap[startDay] = BlockWithTab(
        tabSize: daysInBlock,
        blockVM: block,
      );
    }

    return Map.fromEntries(
      blocksMap.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
  }
}
