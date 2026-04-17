import '../../../domain/models/Booking/booking.dart';
import 'booking_repository.dart';

class BookingRepositoryMock implements BookingRepository {
  final Map<String, Booking> _bookingsByUser = {};

  @override
  Future<bool> createBooking({
    required String userId,
    required String stationId,
    required int slotNumber,
    required String bikeId,
  }) async {
    final DateTime now = DateTime.now();
    _bookingsByUser[userId] = Booking(
      id: 'mock_booking_${now.millisecondsSinceEpoch}',
      stationName: stationId,
      slotNumber: slotNumber,
      bookingTime: now,
      bikeId: bikeId,
    );
    return true;
  }

  @override
  Future<Booking?> getActiveBooking(String userId) async {
    return _bookingsByUser[userId];
  }
}
