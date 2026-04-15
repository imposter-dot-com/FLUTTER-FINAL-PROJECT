import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../../../domain/models/Station/station.dart';
import '../../../theme/theme.dart';
import '../../../utils/async_value.dart';
import '../view_model/stations_map_view_model.dart';
import 'station_bottom_indicator.dart';
import 'station_search_bar.dart';

class StationsMapContent extends StatefulWidget {
  const StationsMapContent({super.key});

  @override
  State<StationsMapContent> createState() => _StationsMapContentState();
}

class _StationsMapContentState extends State<StationsMapContent> {
  // flutter_map uses its own controller to move the camera programmatically.
  final MapController _mapController = MapController();

  // Start the map near the current station area.
  static const LatLng _defaultCenter = LatLng(11.5564, 104.9282);
  static const double _defaultZoom = 13.5;

  void _focusStation(Station station) {
    // When the user selects a station, jump the map closer to that station.
    _mapController.move(
      LatLng(station.lat, station.lng),
      16,
    );
  }

  Widget _buildMarker(Station station) {
    // Available stations use orange. Empty stations use gray.
    final bool hasBikes = station.availableBikesCount > 0;
    final Color pinColor =
        hasBikes ? BikeAppColors.primary : const Color(0xFF7F7F7F);
    final Color numberColor =
        hasBikes ? BikeAppColors.primary : const Color(0xFF7F7F7F);

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        // The outer pin gives the location shape.
        Icon(
          Icons.location_pin,
          color: pinColor,
          size: 62,
        ),
        Positioned(
          top: 11,
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              // The white badge makes the bike count easier to read.
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(
                  color: Color(0x16000000),
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              '${station.availableBikesCount}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: numberColor,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                height: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Marker> _buildMarkers(
    StationsMapViewModel viewModel,
    List<Station> stations,
  ) {
    // Convert each station into one map marker.
    return stations.map((station) {
      return Marker(
        point: LatLng(station.lat, station.lng),
        width: 62,
        height: 70,
        child: GestureDetector(
          onTap: () {
            // Save the selected station and move the camera to it.
            viewModel.selectStation(station);
            _focusStation(station);
          },
          child: _buildMarker(station),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final StationsMapViewModel viewModel = context.watch<StationsMapViewModel>();

    switch (viewModel.stationsValue.state) {
      case AsyncValueState.loading:
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );

      case AsyncValueState.error:
        return Scaffold(
          body: Center(
            child: Text(
              'Error: ${viewModel.stationsValue.error}',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        );

      case AsyncValueState.success:
        // Only the filtered stations are shown on the map.
        final List<Station> stations = viewModel.filteredStations;

        return Scaffold(
          body: Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: const MapOptions(
                  // The first camera position shown when the map opens.
                  initialCenter: _defaultCenter,
                  initialZoom: _defaultZoom,
                ),
                children: [
                  TileLayer(
                    // OpenStreetMap tiles draw the base map.
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.bike_renting_app',
                  ),
                  MarkerLayer(
                    // This layer draws the station pins on top of the map.
                    markers: _buildMarkers(viewModel, stations),
                  ),
                ],
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      StationSearchBar(
                        controller: viewModel.searchController,
                        onChanged: viewModel.updateSearchQuery,
                        onSubmitted: () {
                          // Search submit focuses the first visible result.
                          final Station? station =
                              viewModel.selectFirstFilteredStation();

                          if (station != null) {
                            _focusStation(station);
                          }
                        },
                        onMenuTap: () {
                          // Close the keyboard when the side button is pressed.
                          FocusScope.of(context).unfocus();
                        },
                      ),
                      if (viewModel.searchController.text.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 12),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: BikeAppColors.secondary,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x12000000),
                                blurRadius: 12,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.place_outlined),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  // Show how many stations match the current search.
                                  '${stations.length} station(s) found',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const Spacer(),
                      // Keep the bottom indicator simple and always visible.
                      const StationBottomIndicator(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
    }
  }
}
