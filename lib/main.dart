import 'package:bike_renting_app/data/repositories/bike_pass/bike_pass_repository.dart';
import 'package:bike_renting_app/data/repositories/bike_pass/bike_pass_repository_firebase.dart';
import 'package:bike_renting_app/data/repositories/bike_pass/bike_pass_repository_mock.dart';
import 'package:bike_renting_app/data/repositories/booking/booking_repository.dart';
import 'package:bike_renting_app/data/repositories/booking/booking_repository_mock.dart';
import 'package:bike_renting_app/data/repositories/booking/booking_repository_firebase.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/repositories/station/station_repository.dart';
import 'data/repositories/station/station_repository_firebase.dart';
import 'ui/screens/stations_map/stations_map_screen.dart';
import 'ui/theme/theme.dart';

// user just for mocking cus we haven't implemented auth
// and also mock book and pass repo for testing purposes
const String currentUserId = 'user_001';
const bool useMockPassRepository = true;
const bool useMockBookingRepository = true;

void main() {
  // inject repo to the whole app muahahha
  runApp(
    MultiProvider(
      providers: [
        Provider<StationRepository>(create: (_) => StationRepositoryFirebase()),
        Provider<BikePassRepository>(
          create: (_) => useMockPassRepository
              ? BikePassRepositoryMock()
              : BikePassRepositoryFirebase(),
        ),
        Provider<BookingRepository>(
          create: (_) => useMockBookingRepository
              ? BookingRepositoryMock()
              : BookingRepositoryFirebase(),
        ),
      ],
      child: const BikeRentingApp(),
    ),
  );
}

class BikeRentingApp extends StatelessWidget {
  const BikeRentingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const StationsMapScreen(),
    );
  }
}
