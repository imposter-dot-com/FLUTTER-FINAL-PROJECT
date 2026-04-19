import 'dart:async';

import 'package:bike_renting_app/data/repositories/station/station_repository.dart';
import 'package:bike_renting_app/domain/models/Station/station.dart';
import 'package:bike_renting_app/ui/screens/stations_map/view_model/stations_map_view_model.dart';
import 'package:bike_renting_app/ui/utils/async_value.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StationsMapViewModel', () {
    late StreamController<List<Station>> controller;
    late _FakeStationRepository repository;

    setUp(() {
      controller = StreamController<List<Station>>();
      repository = _FakeStationRepository(controller.stream);
    });

    tearDown(() async {
      await controller.close();
    });

    test(
      'filters stations by search query and selects first filtered station',
      () async {
        final viewModel = StationsMapViewModel(stationRepository: repository);

        controller.add(_stations);
        await Future<void>.delayed(Duration.zero);

        viewModel.updateSearchQuery('central');

        expect(viewModel.filteredStations.map((station) => station.id), ['1']);
        expect(viewModel.selectFirstFilteredStation()?.id, '1');
        expect(viewModel.selectedStation?.id, '1');

        viewModel.dispose();
      },
    );

    test(
      'keeps the selected station in sync when repository data changes',
      () async {
        final viewModel = StationsMapViewModel(stationRepository: repository);

        controller.add(_stations);
        await Future<void>.delayed(Duration.zero);
        viewModel.selectStation(_stations.first);

        controller.add([
          _station(id: '1', name: 'Central Station', occupiedSlots: const [1]),
        ]);
        await Future<void>.delayed(Duration.zero);

        expect(viewModel.selectedStation?.id, '1');
        expect(viewModel.selectedStation?.availableBikesCount, 1);

        viewModel.dispose();
      },
    );

    test(
      'selecting a search suggestion updates the derived query and selection',
      () async {
        final viewModel = StationsMapViewModel(stationRepository: repository);

        controller.add(_stations);
        await Future<void>.delayed(Duration.zero);

        viewModel.selectSearchSuggestion(_stations.last);

        expect(viewModel.selectedStation?.id, '2');
        expect(viewModel.searchQuery, 'riverfront hub');
        expect(viewModel.filteredStations.map((station) => station.id), ['2']);

        viewModel.dispose();
      },
    );

    test('exposes an error state when station loading fails', () async {
      final viewModel = StationsMapViewModel(stationRepository: repository);

      controller.addError(Exception('boom'));
      await Future<void>.delayed(Duration.zero);

      expect(viewModel.stationsValue.state, AsyncValueState.error);
      expect(viewModel.stationsValue.error, isA<Exception>());

      viewModel.dispose();
    });
  });
}

class _FakeStationRepository implements StationRepository {
  _FakeStationRepository(this._stream);

  final Stream<List<Station>> _stream;

  @override
  Future<List<Station>> getAllStations() async => _stations;

  @override
  Future<Station> getStationById(String id) async {
    return _stations.firstWhere((station) => station.id == id);
  }

  @override
  Stream<List<Station>> watchStations() => _stream;
}

List<Station> get _stations => [
  _station(id: '1', name: 'Central Station', occupiedSlots: const [1, 2]),
  _station(id: '2', name: 'Riverfront Hub', occupiedSlots: const [1]),
];

Station _station({
  required String id,
  required String name,
  required List<int> occupiedSlots,
}) {
  return Station(
    id: id,
    name: name,
    lat: 11.0,
    lng: 104.0,
    slots: List<BikeSlot>.generate(3, (index) {
      final int slotNumber = index + 1;
      final bool isOccupied = occupiedSlots.contains(slotNumber);

      return BikeSlot(
        number: slotNumber,
        bikeId: isOccupied ? 'bike-$slotNumber' : null,
        isOccupied: isOccupied,
      );
    }),
  );
}
