import '../../../domain/models/Booking/booking.dart';

abstract class BookingRepository {
  Future<bool> createBooking({
    required String userId,
    required String stationId,
    required int slotNumber,
    required String bikeId,
  });

  Future<Booking?> getActiveBooking(String userId);

  Future<void> endBooking(String bookingId);
}
