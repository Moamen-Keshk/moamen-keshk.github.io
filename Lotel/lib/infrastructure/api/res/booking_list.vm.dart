import 'package:lotel_pms/app/api/view_models/booking.vm.dart';
import 'package:lotel_pms/infrastructure/api/res/booking.service.dart';
import 'package:lotel_pms/app/global/selected_property.global.dart';
import 'package:lotel_pms/app/req/request.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:logging/logging.dart';

// 👉 NEW: Import the socket_io_client
import 'package:socket_io_client/socket_io_client.dart' as io;

class BookingListVM extends StateNotifier<List<BookingVM>> {
  static final Logger _logger = Logger('BookingListVM');

  final BookingService bookingService;
  final int propertyId;
  final int year;
  final int month;

  // 👉 NEW: Socket instance
  io.Socket? _socket;

  BookingListVM(
    this.propertyId,
    this.year,
    this.month,
    this.bookingService, {
    bool autoFetch = true,
  }) : super(const []) {
    if (autoFetch) {
      fetchBookings();
    }
    // 👉 NEW: Initialize WebSockets when the VM is created
    _initWebSockets();
  }

  // 👉 NEW: WebSocket Initialization Method
  void _initWebSockets() {
    final String backendUrl = baseURL;

    _socket = io.io(backendUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    _socket?.onConnect((_) {
      _logger.info('Connected to PMS realtime sync');
    });

    // Listen for the event emitted by the Celery worker / Flask-SocketIO
    _socket?.on('calendar_updated', (data) {
      _logger.fine('WebSocket calendar_updated event received: $data');

      // 👉 BULLETPROOF TYPE CHECK
      if (data['property_id'].toString() == propertyId.toString()) {
        _logger.info('Property match for $propertyId. Fetching new bookings.');
        fetchBookings();
      } else {
        _logger.fine(
          'Ignoring event for property ${data['property_id']} while viewing $propertyId.',
        );
      }
    });

    _socket?.onDisconnect((_) {
      _logger.info('Disconnected from PMS realtime sync');
    });
  }

  // 👉 NEW: Always dispose of the socket to prevent memory leaks
  @override
  void dispose() {
    _socket?.disconnect();
    _socket?.dispose();
    super.dispose();
  }

  Future<void> fetchBookings() async {
    final res = await bookingService.getAllBookings(propertyId, year, month);
    state = [...res.map((booking) => BookingVM(booking))];
  }

  Future<void> fetchBookingsByDate(DateTime date, String bookingState) async {
    final res =
        await bookingService.getBookingsByDate(propertyId, date, bookingState);
    state = [...res.map((booking) => BookingVM(booking))];
  }

  Future<bool> addToBookings(Map<String, dynamic> booking) async {
    if (await bookingService.addBooking(propertyId, booking)) {
      await fetchBookings();
      return true;
    }
    return false;
  }

  Future<bool> editBooking(
    int bookingId,
    Map<String, dynamic> updatedData,
  ) async {
    try {
      final success =
          await bookingService.editBooking(propertyId, bookingId, updatedData);
      if (success) {
        await fetchBookings();
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<bool> deleteBooking(String bookingId) async {
    final success = await bookingService.deleteBooking(propertyId, bookingId);
    if (success) {
      state = state.where((b) => b.booking.id != bookingId).toList();
    }
    return success;
  }

  Future<bool> checkInBooking(int bookingId) async {
    final success = await bookingService.checkInBooking(propertyId, bookingId);
    if (success) {
      await fetchBookings();
    }
    return success;
  }

  Future<bool> checkOutBooking(int bookingId) async {
    final success = await bookingService.checkOutBooking(propertyId, bookingId);
    if (success) {
      await fetchBookings();
    }
    return success;
  }

  Future<BookingVM?> getBookingById(String bookingId) async {
    final booking = await bookingService.getBookingById(propertyId, bookingId);
    if (booking != null) {
      return BookingVM(booking);
    }
    return null;
  }

  Future<bool> sendGuestMessage(
      int bookingId, String subject, String message) async {
    try {
      await bookingService.sendGuestMessage(
        propertyId,
        bookingId,
        subject,
        message,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> extendBooking(
    int bookingId,
    String newCheckOutDate, {
    bool isPaid = false,
    double extraCost = 0.0,
  }) async {
    final success = await bookingService.extendBooking(
      propertyId,
      bookingId,
      newCheckOutDate,
      isPaid: isPaid,
      extraCost: extraCost,
    );

    if (success) {
      await fetchBookings();
    }
    return success;
  }

  Future<Map<String, dynamic>> checkExtensionAvailability(
      int roomId, String currentCheckOut, String newCheckOut) async {
    return await bookingService.checkExtensionAvailability(
        propertyId, roomId, currentCheckOut, newCheckOut);
  }

  Future<bool> updatePaymentStatus(
      int bookingId, int newPaymentStatusId) async {
    final success = await bookingService.editBooking(propertyId, bookingId, {
      'payment_status_id': newPaymentStatusId,
    });

    if (success) {
      await fetchBookings();
    }
    return success;
  }

  Future<bool> recordPayment(int bookingId, double newAmountPaid) async {
    final success = await bookingService.editBooking(propertyId, bookingId, {
      'amount_paid': newAmountPaid,
    });

    if (success) {
      await fetchBookings();
    }
    return success;
  }
}

final selectedBookingIdProvider = StateProvider<int?>((ref) => null);

final bookingListVM =
    StateNotifierProvider<BookingListVM, List<BookingVM>>((ref) {
  final propertyId = ref.watch(selectedPropertyVM) ?? 0;
  final selectedMonth = ref.watch(selectedMonthVM);

  return BookingListVM(
    propertyId,
    selectedMonth.year,
    selectedMonth.month,
    BookingService(),
    autoFetch: true,
  );
});

final bookingListByDateVM = StateNotifierProvider.family<
    BookingListVM,
    List<BookingVM>,
    (int propertyId, DateTime date, String bookingState)>((ref, args) {
  final (propertyId, date, bookingState) = args;

  return BookingListVM(
    propertyId,
    date.year,
    date.month,
    BookingService(),
    autoFetch: false,
  )..fetchBookingsByDate(date, bookingState);
});

final bookingIdProvider = StateProvider<int?>((ref) => null);
