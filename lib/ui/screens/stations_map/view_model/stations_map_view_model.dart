import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../data/repositories/station/station_repository.dart';
import '../../../../domain/models/Station/station.dart';
import '../../../utils/async_value.dart';

class StationsMapViewModel extends ChangeNotifier {
  final StationRepository stationRepository;

  final TextEditingController searchController = TextEditingController();

  AsyncValue<List<Station>> _stationsValue = AsyncValue.loading();
  Station? _selectedStation;
  List<Station> _filteredStations = const <Station>[];
  StreamSubscription<List<Station>>? _stationsSubscription;
  String _searchQuery = '';

  StationsMapViewModel({required this.stationRepository}) {
    searchController.addListener(_handleSearchChanged);
    // Start listening as soon as the screen state is created.
    _subscribeToStations();
  }

  AsyncValue<List<Station>> get stationsValue => _stationsValue;
  Station? get selectedStation => _selectedStation;
  List<Station> get filteredStations => _filteredStations;
  bool get hasSearchQuery => _searchQuery.isNotEmpty;
  bool get showSearchSuggestions => hasSearchQuery;
  List<Station> get searchSuggestions =>
      List<Station>.unmodifiable(_filteredStations.take(5));

  String get searchResultsLabel {
    if (_filteredStations.isEmpty) {
      return 'No stations match your search';
    }

    return '${_filteredStations.length} station(s) found';
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
    _filteredStations = _filterStations(
      _stationsValue.data ?? const <Station>[],
    );
    notifyListeners();
  }

  void selectStation(Station station) {
    if (_selectedStation == station) {
      return;
    }

    _selectedStation = station;
    notifyListeners();
  }

  Station? selectFirstFilteredStation() {
    if (_filteredStations.isEmpty) {
      return null;
    }

    final Station station = _filteredStations.first;
    selectSearchSuggestion(station);
    return station;
  }

  void selectSearchSuggestion(Station station) {
    final String searchText = station.name;
    final String nextQuery = searchText.trim().toLowerCase();

    _searchQuery = nextQuery;
    _selectedStation = station;
    _filteredStations = _filterStations(
      _stationsValue.data ?? const <Station>[],
    );

    if (searchController.text != searchText) {
      searchController.value = TextEditingValue(
        text: searchText,
        selection: TextSelection.collapsed(offset: searchText.length),
      );
    }

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
    // Repository emits station snapshots; this keeps the map reactive.
    _stationsSubscription = stationRepository.watchStations().listen(
      _handleStationsUpdated,
      onError: _handleStationsError,
    );
  }

  void _handleStationsUpdated(List<Station> stations) {
    final List<Station> nextStations = List<Station>.unmodifiable(stations);
    final Station? nextSelectedStation = _resolveSelectedStation(nextStations);
    // Filtering is always derived from the latest station snapshot plus the search query.
    final List<Station> nextFilteredStations = _filterStations(nextStations);

    if (_stationsValue.state == AsyncValueState.success &&
        _stationsListEquals(_stationsValue.data, nextStations) &&
        _selectedStation == nextSelectedStation &&
        _stationsListEquals(_filteredStations, nextFilteredStations)) {
      return;
    }

    _stationsValue = AsyncValue.success(nextStations);
    _selectedStation = nextSelectedStation;
    _filteredStations = nextFilteredStations;
    notifyListeners();
  }

  void _handleStationsError(Object error) {
    _stationsValue = AsyncValue.error(error);
    notifyListeners();
  }

  void _handleSearchChanged() {
    updateSearchQuery(searchController.text);
  }

  Station? _resolveSelectedStation(List<Station> stations) {
    final Station? currentSelectedStation = _selectedStation;
    if (currentSelectedStation == null) {
      return null;
    }

    for (final Station station in stations) {
      if (station.id == currentSelectedStation.id) {
        return station;
      }
    }

    return null;
  }

  List<Station> _filterStations(List<Station> stations) {
    if (_searchQuery.isEmpty) {
      return stations;
    }

    return List<Station>.unmodifiable(
      stations
          .where((station) => station.name.toLowerCase().contains(_searchQuery))
          .toList(growable: false),
    );
  }

  @override
  void dispose() {
    searchController.removeListener(_handleSearchChanged);
    _stationsSubscription?.cancel();
    searchController.dispose();
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
