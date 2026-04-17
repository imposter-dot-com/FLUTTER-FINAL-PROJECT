import 'package:bike_renting_app/ui/screens/booking/view_model/booking_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/repositories/bike_pass/bike_pass_repository.dart';
import '../../../data/repositories/booking/booking_repository.dart';
import '../../../domain/models/Station/station.dart';
import '../booking/widgets/booking_content.dart';

class BookingScreen extends StatelessWidget {
  final String userId;
  final Station station;
  final BikeSlot slot;
  final void Function(String stationId, int slotNumber)? onBookingSuccess;

  const BookingScreen({
    super.key,
    required this.userId,
    required this.station,
    required this.slot,
    this.onBookingSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BookingViewModel(
        bikePassRepository: context.read<BikePassRepository>(),
        bookingRepository: context.read<BookingRepository>(),
        userId: userId,
        station: station,
        onBookingSuccess: onBookingSuccess,
        initialSlot: slot,
      ),
      child: const BookingContent(),
    );
  }
}
