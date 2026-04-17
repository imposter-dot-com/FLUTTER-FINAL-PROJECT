import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../domain/models/Booking/booking.dart';
import '../../dtos/booking_dto.dart';
import '../../../remote/firebase_constants.dart';
import 'booking_repository.dart';

class BookingRepositoryFirebase implements BookingRepository {
  Booking? _cachedBooking;
  String? _cachedUserId;

  @override
  Future<bool> createBooking({
    required String userId,
    required String stationId,
    required int slotNumber,
    required String bikeId,
  }) async {
    final stationPathId = _normalizeStationPathId(stationId);

    final _ResolvedSlot? resolvedSlot = await _resolveSlotByNumber(
      stationPathId: stationPathId,
      slotNumber: slotNumber,
    );

    if (resolvedSlot == null) {
      throw Exception('Failed to verify slot availability');
    }

    // In this data model, isOccupied=true means there is a bike in this slot.
    final bool hasBike =
        resolvedSlot.data['isOccupied'] == true &&
        resolvedSlot.data['bikeId'] != null;
    if (!hasBike) {
      throw Exception('This bike slot is already taken');
    }

    // Fetch station name for the booking record.
    final stationUri = Uri.https(
      FirebaseConstants.databaseBaseUrl,
      '/stations/$stationPathId/name.json',
    );
    final stationResponse = await http.get(stationUri);
    final stationName = stationResponse.statusCode == 200
        ? (json.decode(stationResponse.body) as String? ?? stationId)
        : stationId;

    final bookingId =
        'booking_${DateTime.now().millisecondsSinceEpoch}_$userId';
    final bookingTime = DateTime.now();

    // Atomic multi-path PATCH.
    final multiPatchUri = Uri.https(
      FirebaseConstants.databaseBaseUrl,
      '/.json',
    );

    final bookingData = {
      BookingDTO.idKey: bookingId,
      BookingDTO.stationNameKey: stationName,
      BookingDTO.slotNumberKey: slotNumber,
      BookingDTO.bookingTimeKey: bookingTime.toIso8601String(),
      BookingDTO.bikeIdKey: bikeId,
    };

    final payload = {
      'users/$userId/currentBooking': bookingData,
      'stations/$stationPathId/slots/${resolvedSlot.index}/isOccupied': false,
      'stations/$stationPathId/slots/${resolvedSlot.index}/bikeId': null,
    };

    final patchResponse = await http.patch(
      multiPatchUri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(payload),
    );

    if (patchResponse.statusCode != 200) {
      throw Exception('Booking transaction failed: ${patchResponse.body}');
    }

    // Update cache immediately.
    _cachedUserId = userId;
    _cachedBooking = Booking(
      id: bookingId,
      stationName: stationName,
      slotNumber: slotNumber,
      bookingTime: bookingTime,
      bikeId: bikeId,
    );

    return true;
  }

  @override
  Future<Booking?> getActiveBooking(String userId) async {
    // Return cache if it's for the same user.
    if (_cachedUserId == userId && _cachedBooking != null) {
      return _cachedBooking;
    }

    final uri = Uri.https(
      FirebaseConstants.databaseBaseUrl,
      '/users/$userId/currentBooking.json',
    );
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch active booking');
    }

    if (response.body == 'null') {
      _cachedUserId = userId;
      _cachedBooking = null;
      return null;
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    final booking = BookingDTO.fromJson(data[BookingDTO.idKey] as String, data);

    _cachedUserId = userId;
    _cachedBooking = booking;

    return booking;
  }

  String _normalizeStationPathId(String stationId) {
    if (stationId.startsWith('station_')) {
      return stationId.split('_').last;
    }
    return stationId;
  }

  Future<_ResolvedSlot?> _resolveSlotByNumber({
    required String stationPathId,
    required int slotNumber,
  }) async {
    final slotsUri = Uri.https(
      FirebaseConstants.databaseBaseUrl,
      '/stations/$stationPathId/slots.json',
    );
    final slotsResponse = await http.get(slotsUri);

    if (slotsResponse.statusCode != 200 || slotsResponse.body == 'null') {
      return null;
    }

    final dynamic decoded = json.decode(slotsResponse.body);
    if (decoded is! List) {
      return null;
    }

    for (int index = 0; index < decoded.length; index++) {
      final dynamic rawSlot = decoded[index];
      if (rawSlot is! Map) continue;

      final Map<String, dynamic> slotData = Map<String, dynamic>.from(rawSlot);
      if (slotData['number'] == slotNumber) {
        return _ResolvedSlot(index: index, data: slotData);
      }
    }

    return null;
  }
}

class _ResolvedSlot {
  final int index;
  final Map<String, dynamic> data;

  _ResolvedSlot({required this.index, required this.data});
}
