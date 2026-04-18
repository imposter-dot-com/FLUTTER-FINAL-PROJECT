import 'package:bike_renting_app/data/repositories/booking/booking_repository.dart';
import 'package:bike_renting_app/domain/models/Booking/booking.dart';
import 'package:bike_renting_app/ui/utils/async_value.dart';
import 'package:flutter/material.dart';

class CurrentBookingViewModel extends ChangeNotifier {
  final BookingRepository bookingRepository;
  final String userId;

  AsyncValue<Booking?> bookingValue = AsyncValue.loading();
  bool _unlocked = false;

  bool get unlocked => _unlocked;
  Booking? get activeBooking =>
      bookingValue.state == AsyncValueState.success ? bookingValue.data : null;
  bool get hasActiveBooking => activeBooking != null;

  CurrentBookingViewModel({
    required this.bookingRepository,
    required this.userId,
  }) {
    fetchBooking();
  }

  Future<void> fetchBooking() async {
    bookingValue = AsyncValue.loading();
    notifyListeners();
    try {
      final booking = await bookingRepository.getActiveBooking(userId);
      bookingValue = AsyncValue.success(booking);
    } catch (e) {
      bookingValue = AsyncValue.error(e);
    }
    notifyListeners();
  }

  Future<void> onNewBookingCreated() async {
    _unlocked = false;
    await fetchBooking();
  }

  void unlockBike() {
    _unlocked = true;
    notifyListeners();
  }

  void cancelBooking() {
    bookingValue = AsyncValue.success(null);
    _unlocked = false;
    notifyListeners();
  }
}
