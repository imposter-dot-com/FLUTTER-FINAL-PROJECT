import '../../../domain/models/Station/station.dart';

abstract class StationRepository {
  Future<List<Station>> getAllStations();

  // Emit live station updates from the data source so the UI stays in sync.
  Stream<List<Station>> watchStations();

  Future<Station> getStationById(String id);
}
