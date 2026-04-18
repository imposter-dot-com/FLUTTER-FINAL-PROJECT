import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/repositories/station/station_repository.dart';
import 'view_model/stations_map_view_model.dart';
import 'widgets/stations_map_content.dart';

class StationsMapScreen extends StatelessWidget {
  const StationsMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // The map screen gets all station state through this view model.
    return ChangeNotifierProvider(
      create: (context) => StationsMapViewModel(
        stationRepository: context.read<StationRepository>(),
      ),
      child: const StationsMapContent(),
    );
  }
}
