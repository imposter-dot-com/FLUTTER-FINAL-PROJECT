import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;

import '../../../domain/models/Station/station.dart';
import '../../dtos/station_dto.dart';
import '../../../remote/firebase_constants.dart';
import 'station_repository.dart';

class StationRepositoryFirebase implements StationRepository {
  StationRepositoryFirebase({FirebaseDatabase? database})
    : _providedDatabase = database;

  static const String _stationsPath = 'stations';

  final FirebaseDatabase? _providedDatabase;

  List<Station>? _cachedStations;
  Future<FirebaseDatabase?>? _databaseFuture;

  final Uri stationsUri = Uri.https(
    FirebaseConstants.databaseBaseUrl,
    '/stations.json',
  );

  @override
  Future<List<Station>> getAllStations() async {
    if (_cachedStations != null) {
      return _cachedStations!;
    }

    final FirebaseDatabase? database = await _getDatabase();
    final List<Station> stations;

    if (database == null) {
      stations = await _fetchStationsFromRest();
    } else {
      final DataSnapshot snapshot = await database.ref(_stationsPath).get();
      stations = _parseStationsValue(snapshot.value);
    }

    return _cacheStations(stations);
  }

  @override
  Stream<List<Station>> watchStations() async* {
    final FirebaseDatabase? database = await _getDatabase();

    if (database == null) {
      // Without Firebase app setup, fall back to a single snapshot instead of polling.
      yield await getAllStations();
      return;
    }

    // Firebase Realtime Database is the live source for map station updates.
    yield* database
        .ref(_stationsPath)
        .onValue
        .map((event) => _parseStationsValue(event.snapshot.value))
        .distinct(_stationsEqual)
        .map(_cacheStations);
  }

  @override
  Future<Station> getStationById(String id) async {
    final List<Station> stations = await getAllStations();

    return stations.firstWhere(
      (station) => station.id == id,
      orElse: () => throw Exception('Station with id $id not found'),
    );
  }

  Future<FirebaseDatabase?> _getDatabase() {
    if (_providedDatabase != null) {
      return Future<FirebaseDatabase?>.value(_providedDatabase);
    }

    _databaseFuture ??= _createDatabaseOrNull();
    return _databaseFuture!;
  }

  Future<FirebaseDatabase?> _createDatabaseOrNull() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }

      return FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: FirebaseConstants.databaseUrl,
      );
    } catch (_) {
      return null;
    }
  }

  List<Station> _cacheStations(List<Station> stations) {
    _cachedStations = List<Station>.unmodifiable(stations);
    return _cachedStations!;
  }

  Future<List<Station>> _fetchStationsFromRest() async {
    final http.Response response = await http.get(stationsUri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load stations');
    }

    return _parseStationsValue(json.decode(response.body));
  }

  List<Station> _parseStationsValue(Object? value) {
    if (value == null) {
      return const <Station>[];
    }

    // Support both list-shaped and keyed station payloads from the database.
    if (value is List<dynamic>) {
      return List<Station>.unmodifiable(_stationsFromList(value));
    }

    if (value is Map<Object?, Object?>) {
      final List<MapEntry<Object?, Object?>> entries = value.entries.toList()
        ..sort((left, right) => '${left.key}'.compareTo('${right.key}'));
      return List<Station>.unmodifiable(
        entries
            .where((entry) => entry.value != null)
            .map(
              (entry) => StationDTO.fromJson(
                '${entry.key}',
                Map<String, dynamic>.from(entry.value! as Map),
              ),
            )
            .toList(growable: false),
      );
    }

    throw const FormatException('Unexpected station payload');
  }

  List<Station> _stationsFromList(List<dynamic> stationJson) {
    final List<Station> stations = <Station>[];

    for (int index = 0; index < stationJson.length; index++) {
      final dynamic stationValue = stationJson[index];
      if (stationValue == null) {
        continue;
      }

      stations.add(
        StationDTO.fromJson(
          '$index',
          Map<String, dynamic>.from(stationValue as Map),
        ),
      );
    }

    return stations;
  }
}

bool _stationsEqual(List<Station> left, List<Station> right) {
  if (identical(left, right)) return true;
  if (left.length != right.length) return false;

  for (int index = 0; index < left.length; index++) {
    if (left[index] != right[index]) {
      return false;
    }
  }

  return true;
}
