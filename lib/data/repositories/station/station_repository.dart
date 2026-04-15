import '../../../domain/models/Station/station.dart';

abstract class StationRepository {
  Future<List<Station>> getAllStations();

  Stream<List<Station>> watchStations();

  Future<Station> getStationById(String id);
}
