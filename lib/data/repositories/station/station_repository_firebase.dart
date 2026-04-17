import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../domain/models/Station/station.dart';
import '../../dtos/station_dto.dart';
import 'station_repository.dart';
import '../../../remote/firebase_constants.dart';

class StationRepositoryFirebase implements StationRepository {
  // Keep the last station list so the app does not refetch on every rebuild.
  List<Station>? _cachedStations;

  // This endpoint returns the station list stored in Firebase.
  final Uri stationsUri = Uri.https(FirebaseConstants.databaseBaseUrl, '/stations.json');

  @override
  Future<List<Station>> getAllStations() async {
    // Reuse the last successful list if it is already available.
    if (_cachedStations != null) {
      return _cachedStations!;
    }

    final List<Station> stations = await _fetchStations();
    _cachedStations = stations;
    return stations;
  }

  @override
  Stream<List<Station>> watchStations() async* {
    // Send data immediately so the map can render right away.
    yield await getAllStations();

    // Poll again every few seconds so bike availability stays current.
    yield* Stream.periodic(const Duration(seconds: 15)).asyncMap((_) async {
      final List<Station> stations = await _fetchStations();
      _cachedStations = stations;
      return stations;
    });
  }

  @override
  Future<Station> getStationById(String id) async {
    final List<Station> stations = await getAllStations();

    return stations.firstWhere(
      (station) => station.id == id,
      orElse: () => throw Exception('Station with id $id not found'),
    );
  }

  Future<List<Station>> _fetchStations() async {
    // Fetch the latest station list from Firebase.
    final http.Response response = await http.get(stationsUri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load stations');
    }

    if (response.body == 'null') {
      return [];
    }

    // Firebase returns a JSON array of station objects.
    final List<dynamic> stationJson = json.decode(response.body) as List<dynamic>;
    final List<Station> stations = [];

    // The station objects do not include their own id, so one is generated here.
    for (int index = 0; index < stationJson.length; index++) {
      stations.add(
        StationDTO.fromJson(
          'station_$index',
          Map<String, dynamic>.from(stationJson[index] as Map),
        ),
      );
    }

    return stations;
  }
}
