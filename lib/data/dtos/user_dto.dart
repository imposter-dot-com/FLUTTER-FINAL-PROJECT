import '../../domain/models/User/user.dart';
import 'bike_pass_dto.dart';
import 'booking_dto.dart';

class UserDTO {
  static const String uidKey = 'uid';
  static const String emailKey = 'email';
  static const String activePassKey = 'activePass';
  static const String currentBookingKey = 'currentBooking';

  static User fromJson(String uid, Map<String, dynamic> json) {
    assert(json[uidKey] is String);
    assert(json[emailKey] is String);
    assert(json[activePassKey] == null || json[activePassKey] is Map);
    assert(json[currentBookingKey] == null || json[currentBookingKey] is Map);
    assert(
      json[activePassKey] == null ||
          (Map<String, dynamic>.from(json[activePassKey] as Map))[BikePassDTO.idKey] is String,
    );
    assert(
      json[currentBookingKey] == null ||
          (Map<String, dynamic>.from(json[currentBookingKey] as Map))[BookingDTO.idKey] is String,
    );

    return User(
      uid: uid,
      email: json[emailKey] as String,
      activePass: json[activePassKey] == null
          ? null
          : BikePassDTO.fromJson(
              (Map<String, dynamic>.from(json[activePassKey] as Map))[BikePassDTO.idKey] as String,
              Map<String, dynamic>.from(json[activePassKey] as Map),
            ),
      currentBooking: json[currentBookingKey] == null
          ? null
          : BookingDTO.fromJson(
              (Map<String, dynamic>.from(json[currentBookingKey] as Map))[BookingDTO.idKey] as String,
              Map<String, dynamic>.from(json[currentBookingKey] as Map),
            ),
    );
  }

  Map<String, dynamic> toJson(User user) => {
        uidKey: user.uid,
        emailKey: user.email,
        activePassKey: user.activePass == null ? null : BikePassDTO().toJson(user.activePass!),
        currentBookingKey:
            user.currentBooking == null ? null : BookingDTO().toJson(user.currentBooking!),
      };
}
