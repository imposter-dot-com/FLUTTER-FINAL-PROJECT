import 'package:bike_renting_app/main.dart';
import 'package:bike_renting_app/ui/screens/booking/booking_screen.dart';
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
  static const LatLng _defaultCenter = LatLng(11.5564, 104.9282);
  static const double _defaultZoom = 13.5;

  // Used for search focus and marker taps that should move the visible map.
  final MapController _mapController = MapController();
  // Reuse marker widgets when station data has not changed.
  final Map<String, _CachedMarker> _markerCache = <String, _CachedMarker>{};

  void _focusStation(Station station) {
    _mapController.move(LatLng(station.lat, station.lng), 16);
  }

  Future<void> _handleStationTap(Station station) async {
    final StationsMapViewModel viewModel = context.read<StationsMapViewModel>();
    viewModel.selectStation(station);
    _focusStation(station);

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BookingScreen(
          userId: currentUserId,
          station: station,
          slot: station.slots.first,
        ),
      ),
    );
  }

  List<Marker> _buildMarkers(List<Station> stations) {
    final Map<String, _CachedMarker> nextCache = <String, _CachedMarker>{};
    final List<Marker> markers = <Marker>[];

    for (final Station station in stations) {
      final _CachedMarker? cachedMarker = _markerCache[station.id];
      if (cachedMarker != null && cachedMarker.station == station) {
        nextCache[station.id] = cachedMarker;
        markers.add(cachedMarker.marker);
        continue;
      }

      final Marker marker = Marker(
        key: ValueKey<String>('station-marker-${station.id}'),
        point: LatLng(station.lat, station.lng),
        width: 62,
        height: 70,
        child: GestureDetector(
          onTap: () => _handleStationTap(station),
          child: _StationMarker(station: station),
        ),
      );

      nextCache[station.id] = _CachedMarker(station: station, marker: marker);
      markers.add(marker);
    }

    _markerCache
      ..clear()
      ..addAll(nextCache);

    return List<Marker>.unmodifiable(markers);
  }

  @override
  Widget build(BuildContext context) {
    return Selector<StationsMapViewModel, AsyncValueState>(
      selector: (_, viewModel) => viewModel.stationsValue.state,
      builder: (context, state, _) {
        switch (state) {
          case AsyncValueState.loading:
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          case AsyncValueState.error:
            return const Scaffold(body: _StationsErrorView());
          case AsyncValueState.success:
            return Scaffold(
              body: Stack(
                children: [
                  // Base map layer: OSM tiles plus station markers from the view model.
                  FlutterMap(
                    mapController: _mapController,
                    options: const MapOptions(
                      initialCenter: _defaultCenter,
                      initialZoom: _defaultZoom,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.bike_renting_app',
                      ),
                      // Only stations that match the current search query stay visible.
                      Selector<StationsMapViewModel, List<Station>>(
                        selector: (_, viewModel) => viewModel.filteredStations,
                        builder: (context, stations, child) {
                          return MarkerLayer(markers: _buildMarkers(stations));
                        },
                      ),
                    ],
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Search updates the filtered station list and can recenter the map.
                          StationSearchBar(
                            controller: context
                                .read<StationsMapViewModel>()
                                .searchController,
                            onSubmitted: () {
                              final Station? station = context
                                  .read<StationsMapViewModel>()
                                  .selectFirstFilteredStation();

                              if (station != null) {
                                FocusScope.of(context).unfocus();
                                _focusStation(station);
                              }
                            },
                            onMenuTap: () {
                              FocusScope.of(context).unfocus();
                            },
                          ),
                          _SearchSuggestionsPanel(
                            onStationSelected: (station) {
                              context
                                  .read<StationsMapViewModel>()
                                  .selectSearchSuggestion(station);
                              FocusScope.of(context).unfocus();
                              _focusStation(station);
                            },
                          ),
                          const Spacer(),
                          const StationBottomIndicator(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
        }
      },
    );
  }
}

class _StationMarker extends StatelessWidget {
  const _StationMarker({required this.station});

  final Station station;

  @override
  Widget build(BuildContext context) {
    // Marker color and count both come from the station's computed bike availability.
    final bool hasBikes = station.hasBikes;
    final Color pinColor = hasBikes
        ? BikeAppColors.primary
        : const Color(0xFF7F7F7F);

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Icon(Icons.location_pin, color: pinColor, size: 62),
        Positioned(
          top: 11,
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
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
                color: pinColor,
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
}

class _SearchSuggestionsPanel extends StatelessWidget {
  const _SearchSuggestionsPanel({required this.onStationSelected});

  final ValueChanged<Station> onStationSelected;

  @override
  Widget build(BuildContext context) {
    return Selector<
      StationsMapViewModel,
      ({bool showSuggestions, List<Station> suggestions})
    >(
      selector: (_, viewModel) => (
        showSuggestions: viewModel.showSearchSuggestions,
        suggestions: viewModel.searchSuggestions,
      ),
      builder: (context, searchState, child) {
        if (!searchState.showSuggestions) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.only(top: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: searchState.suggestions.isEmpty
                ? const _EmptySearchSuggestions()
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (
                        int index = 0;
                        index < searchState.suggestions.length;
                        index++
                      )
                        _SearchSuggestionTile(
                          station: searchState.suggestions[index],
                          showDivider:
                              index != searchState.suggestions.length - 1,
                          onTap: () =>
                              onStationSelected(searchState.suggestions[index]),
                        ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}

class _SearchSuggestionTile extends StatelessWidget {
  const _SearchSuggestionTile({
    required this.station,
    required this.onTap,
    required this.showDivider,
  });

  final Station station;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            border: showDivider
                ? const Border(bottom: BorderSide(color: Color(0xFFF0F0F0)))
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: BikeAppColors.primary.withAlpha(24),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.place_rounded,
                  color: BikeAppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      station.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.pedal_bike_rounded,
                          size: 16,
                          color: station.hasBikes
                              ? BikeAppColors.primary
                              : const Color(0xFF7F7F7F),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${station.availableBikesCount} bike(s) available',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.north_west_rounded,
                color: Color(0xFF7F7F7F),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptySearchSuggestions extends StatelessWidget {
  const _EmptySearchSuggestions();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          const Icon(Icons.search_off_rounded, color: Color(0xFF7F7F7F)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'No stations match your search',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _StationsErrorView extends StatelessWidget {
  const _StationsErrorView();

  @override
  Widget build(BuildContext context) {
    return Selector<StationsMapViewModel, ({String title, String message})>(
      selector: (_, viewModel) =>
          (title: viewModel.errorTitle, message: viewModel.errorMessage),
      builder: (context, errorState, _) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.wifi_tethering_error_rounded,
                  size: 56,
                  color: BikeAppColors.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  errorState.title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  errorState.message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: context.read<StationsMapViewModel>().retry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try again'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CachedMarker {
  const _CachedMarker({required this.station, required this.marker});

  final Station station;
  final Marker marker;
}
