import '../models/Station/station.dart';

abstract class StationRepository {

  // fetch all stations for map views
  Future<List<Station>> getAllStations();

  // real-time stream to  watch stations availability change on live
  Stream<List<Station>> watchStations();

  // fetch specific detail for one station by its id
  Future<Station> getStationById(String id);
}