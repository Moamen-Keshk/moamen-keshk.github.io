import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_academy/infrastructure/courses/res/booking.service.dart';
import 'package:flutter_academy/infrastructure/courses/model/booking.model.dart';
import 'package:flutter_academy/app/courses/view_models/lists/booking_list.vm.dart';
import 'package:flutter_academy/app/courses/view_models/lists/room_list.vm.dart';
import 'package:flutter_academy/app/courses/view_models/lists/payment_status_list.vm.dart';

final roomMappingProvider = Provider<Map<int, String>>((ref) {
  final rooms = ref.watch(roomListVM);
  return {
    for (var room in rooms)
      if (int.tryParse(room.id) != null)
        int.parse(room.id): room.roomNumber.toString()
  };
});

final paymentStatusMappingProvider =
    FutureProvider<Map<int, String>>((ref) async {
  return await PaymentStatusListVM().paymentStatusMapping();
});

class BookingView extends ConsumerWidget {
  const BookingView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingId = ref.watch(bookingIdProvider);
    final roomMapping = ref.watch(roomMappingProvider);
    final paymentStatusMappingAsync = ref.watch(paymentStatusMappingProvider);

    if (bookingId == null) {
      return const Center(child: Text("No booking selected"));
    }

    return paymentStatusMappingAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text("Error: $err")),
      data: (paymentStatusMapping) {
        return FutureBuilder<Booking?>(
          future: BookingService().getBookingById(bookingId.toString()),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }

            final booking = snapshot.data;
            if (booking == null) {
              return const Center(child: Text("Booking not found"));
            }

            final format = DateFormat.yMMMd();

            return Padding(
              padding: const EdgeInsets.all(12),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.start,
                children: [
                  _section("Guest Info", {
                    "Name": "${booking.firstName} ${booking.lastName}",
                    "Email": booking.email ?? "-",
                    "Phone": booking.phone ?? "-",
                    "Adults": "${booking.numberOfAdults}",
                    "Children": "${booking.numberOfChildren}",
                  }),
                  _section("Dates", {
                    "Check-in": format.format(booking.checkIn),
                    "Check-out": format.format(booking.checkOut),
                    "Created": format.format(booking.bookingDate),
                  }),
                  _section("Payment", {
                    "Rate": "£${booking.rate.toStringAsFixed(2)}",
                    "Status": paymentStatusMapping[booking.paymentStatusID] ??
                        "Unknown",
                  }),
                  _section("Meta", {
                    "Room":
                        roomMapping[booking.roomID] ?? 'Room ${booking.roomID}',
                    "Confirmation Number":
                        booking.confirmationNumber.toString(),
                  }),
                  _section("Nightly Rates", {
                    for (var rate in booking.bookingRates)
                      DateFormat('dd MMM').format(rate.rateDate):
                          "£${rate.nightlyRate.toStringAsFixed(2)}"
                  }),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _section(String title, Map<String, String> data) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 260),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              ...data.entries.map((e) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          flex: 1,
                          child: Text(e.key,
                              style: const TextStyle(fontSize: 12),
                              overflow: TextOverflow.ellipsis),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          flex: 1,
                          child: Text(e.value,
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.black87),
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
