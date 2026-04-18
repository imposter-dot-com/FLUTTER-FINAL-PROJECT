import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../data/repositories/station/station_repository.dart';
import '../../../../domain/models/Station/station.dart';
import '../../../utils/async_value.dart';

class StationsMapViewModel extends ChangeNotifier {
  final StationRepository stationRepository;

  AsyncValue<List<Station>> _stationsValue = AsyncValue.loading();
  String? _selectedStationId;
  StreamSubscription<List<Station>>? _stationsSubscription;
  String _searchQuery = '';

  StationsMapViewModel({required this.stationRepository}) {
    // Start listening as soon as the screen state is created.
    _subscribeToStations();
  }

  AsyncValue<List<Station>> get stationsValue => _stationsValue;
  List<Station> get stations => _stationsValue.data ?? const <Station>[];
  String get searchQuery => _searchQuery;
  Station? get selectedStation =>
      _findStationById(_selectedStationId, stations);
  List<Station> get filteredStations => _filterStations(stations, _searchQuery);
  bool get hasSearchQuery => _searchQuery.isNotEmpty;
  bool get showSearchSuggestions => hasSearchQuery;
  List<Station> get searchSuggestions =>
      List<Station>.unmodifiable(filteredStations.take(5));

  String get searchResultsLabel {
    if (filteredStations.isEmpty) {
      return 'No stations match your search';
    }

    return '${filteredStations.length} station(s) found';
  }

  String get errorTitle => 'Unable to load stations';

  String get errorMessage {
    final Object? error = _stationsValue.error;

    if (error is TimeoutException) {
      return 'The request timed out. Check your connection and try again.';
    }

    if (error is FormatException) {
      return 'Station data is unavailable right now. Please try again shortly.';
    }

    return 'We could not load live station data right now. Please try again.';
  }

  void updateSearchQuery(String value) {
    final String nextQuery = value.trim().toLowerCase();
    if (_searchQuery == nextQuery) {
      return;
    }

    _searchQuery = nextQuery;
    notifyListeners();
  }

  void selectStation(Station station) {
    if (_selectedStationId == station.id) {
      return;
    }

    _selectedStationId = station.id;
    notifyListeners();
  }

  Station? selectFirstFilteredStation() {
    if (filteredStations.isEmpty) {
      return null;
    }

    final Station station = filteredStations.first;
    selectSearchSuggestion(station);
    return station;
  }

  void selectSearchSuggestion(Station station) {
    _searchQuery = station.name.trim().toLowerCase();
    _selectedStationId = station.id;
    notifyListeners();
  }

  Future<void> retry() async {
    await _subscribeToStations(showLoading: true);
  }

  Future<void> _subscribeToStations({bool showLoading = false}) async {
    if (showLoading || _stationsValue.state != AsyncValueState.success) {
      _stationsValue = AsyncValue.loading();
      notifyListeners();
    }

    await _stationsSubscription?.cancel();
    _stationsSubscription = stationRepository.watchStations().listen(
      // wehave Data callback (success case and the error handler
      _handleStationsUpdated,
      onError: _handleStationsError,
    );
  }

  void _handleStationsUpdated(List<Station> stations) {
    // w make station immutable to prevent accidentaly write by ui or cache
    final List<Station> nextStations = List<Station>.unmodifiable(stations);

    if (_stationsValue.state == AsyncValueState.success &&
        _stationsListEquals(_stationsValue.data, nextStations)) {
      return;
    }

    _stationsValue = AsyncValue.success(nextStations);
    notifyListeners();
  }

  void _handleStationsError(Object error) {
    _stationsValue = AsyncValue.error(error);
    notifyListeners();
  }

  Station? _findStationById(String? stationId, List<Station> stations) {
    if (stationId == null) {
      return null;
    }

    for (final Station station in stations) {
      if (station.id == stationId) {
        return station;
      }
    }

    return null;
  }

  List<Station> _filterStations(List<Station> stations, String query) {
    if (query.isEmpty) {
      return stations;
    }

    return List<Station>.unmodifiable(
      stations
          .where((station) => station.name.toLowerCase().contains(query))
          .toList(growable: false),
    );
  }

  @override
  void dispose() {
    _stationsSubscription?.cancel();
    super.dispose();
  }
}

bool _stationsListEquals(List<Station>? left, List<Station>? right) {
  if (identical(left, right)) return true;
  if (left == null || right == null || left.length != right.length) {
    return false;
  }

  for (int index = 0; index < left.length; index++) {
    if (left[index] != right[index]) {
      return false;
    }
  }

  return true;
}
