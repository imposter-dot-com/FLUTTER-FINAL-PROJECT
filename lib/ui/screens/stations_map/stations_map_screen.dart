import 'package:bike_renting_app/data/repositories/booking/booking_repository.dart';
import 'package:bike_renting_app/main.dart';
import 'package:bike_renting_app/ui/screens/current_booking/view_model/current_booking_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/repositories/station/station_repository.dart';
import 'view_model/stations_map_view_model.dart';
import 'widgets/stations_map_content.dart';

class StationsMapScreen extends StatelessWidget {
  const StationsMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => StationsMapViewModel(
            stationRepository: context.read<StationRepository>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => CurrentBookingViewModel(
            bookingRepository: context.read<BookingRepository>(),
            userId: currentUserId,
          ),
        ),
      ],
      child: const StationsMapContent(),
    );
  }
}
