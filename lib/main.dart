import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/repositories/station/station_repository.dart';
import 'data/repositories/station/station_repository_firebase.dart';
import 'ui/screens/stations_map/stations_map_screen.dart';
import 'ui/theme/theme.dart';

void main() {
  // Make the station repository available to the whole app.
  runApp(
    MultiProvider(
      providers: [
        Provider<StationRepository>(
          create: (_) => StationRepositoryFirebase(),
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
    // Start the app with the shared theme and the station map screen.
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const StationsMapScreen(),
    );
  }
}
