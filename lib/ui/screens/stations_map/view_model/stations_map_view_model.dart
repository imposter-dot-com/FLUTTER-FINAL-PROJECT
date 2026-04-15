import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../data/repositories/station/station_repository.dart';
import '../../../../domain/models/Station/station.dart';
import '../../../utils/async_value.dart';

class StationsMapViewModel extends ChangeNotifier {
  final StationRepository stationRepository;

  // Keep the search text field controller in the view model.
  final TextEditingController searchController = TextEditingController();

  AsyncValue<List<Station>> stationsValue = AsyncValue.loading();
  Station? selectedStation;

  StreamSubscription<List<Station>>? _stationsSubscription;
  String _searchQuery = '';

  StationsMapViewModel({required this.stationRepository}) {
    _init();
  }

  // Return only the stations that match the current search text.
  List<Station> get filteredStations {
    final List<Station> stations = stationsValue.data ?? [];

    if (_searchQuery.trim().isEmpty) {
      return stations;
    }

    final String query = _searchQuery.toLowerCase();

    return stations
        .where((station) => station.name.toLowerCase().contains(query))
        .toList();
  }

  void _init() {
    // Start in loading mode while the first station list is fetched.
    stationsValue = AsyncValue.loading();

    // Keep listening so the map can refresh when station data changes.
    _stationsSubscription = stationRepository.watchStations().listen(
      (stations) {
        stationsValue = AsyncValue.success(stations);

        // If the user already selected a station, try to keep that selection.
        if (selectedStation != null) {
          try {
            selectedStation = stations.firstWhere(
              (station) => station.id == selectedStation!.id,
            );
          } catch (_) {
            selectedStation = null;
          }
        }

        notifyListeners();
      },
      onError: (error) {
        stationsValue = AsyncValue.error(error);
        notifyListeners();
      },
    );
  }

  void updateSearchQuery(String value) {
    // Save the current search text and rebuild the screen.
    _searchQuery = value;
    notifyListeners();
  }

  void selectStation(Station station) {
    // Save which station the user tapped on.
    selectedStation = station;
    notifyListeners();
  }

  // Search submit uses the first station from the filtered list.
  Station? selectFirstFilteredStation() {
    if (filteredStations.isEmpty) {
      return null;
    }

    selectedStation = filteredStations.first;
    notifyListeners();
    return selectedStation;
  }

  @override
  void dispose() {
    // Clean up the stream and text controller when the screen is removed.
    _stationsSubscription?.cancel();
    searchController.dispose();
    super.dispose();
  }
}
