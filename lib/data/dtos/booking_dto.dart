import '../../domain/models/Booking/booking.dart';

class BookingDTO {
  static const String idKey = 'id';
  static const String stationNameKey = 'stationName';
  static const String slotNumberKey = 'slotNumber';
  static const String bookingTimeKey = 'bookingTime';
  static const String bikeIdKey = 'bikeId';

  static Booking fromJson(String id, Map<String, dynamic> json) {
    assert(json[idKey] is String);
    assert(json[stationNameKey] is String);
    assert(json[slotNumberKey] is int);
    assert(json[bookingTimeKey] is String);
    assert(json[bikeIdKey] is String);

    return Booking(
      id: id,
      stationName: json[stationNameKey] as String,
      slotNumber: json[slotNumberKey] as int,
      bookingTime: DateTime.parse(json[bookingTimeKey] as String),
      bikeId: json[bikeIdKey] as String,
    );
  }

  static Map<String, dynamic> toJson(Booking booking) => {
    idKey: booking.id,
    stationNameKey: booking.stationName,
    slotNumberKey: booking.slotNumber,
    bookingTimeKey: booking.bookingTime.toIso8601String(),
    bikeIdKey: booking.bikeId,
  };
}
