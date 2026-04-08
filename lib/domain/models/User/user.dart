import '../Booking/booking.dart';
import '../Pass/bike_pass.dart';

class User {
  final String uid;
  final String email;
  final BikePass? activePass;
  final Booking? currentBooking;  

  User({required this.uid, required this.email, this.activePass, this.currentBooking});

  bool get canRent => activePass != null && activePass!.isValid  && currentBooking == null;
  
}

