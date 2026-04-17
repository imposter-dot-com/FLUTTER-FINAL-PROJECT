import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../../../data/repositories/bike_pass/bike_pass_repository.dart';
import '../../../../../data/repositories/booking/booking_repository.dart';
import '../../../../../domain/models/Pass/bike_pass.dart';
import '../../../../../domain/models/Station/station.dart';
import '../../../utils/async_value.dart';

enum BookingFlow { hasPass, noPass }

class BookingViewModel extends ChangeNotifier {
  final BikePassRepository bikePassRepository;
  final BookingRepository bookingRepository;
  final String userId;
  final Station station;
  final void Function(String stationId, int slotNumber)? onBookingSuccess;
  BikeSlot? _selectedSlot;
  String _address = "Fetching address..."; // default state
  String get address => _address;
  bool _successHandled = false;
  bool _errorHandled = false;

  BikePass? activePass;
  AsyncValue<bool> bookingState = AsyncValue.success(false);

  BookingViewModel({
    required this.bikePassRepository,
    required this.bookingRepository,
    required this.userId,
    required this.station,
    this.onBookingSuccess,
    BikeSlot? initialSlot,
  }) : _selectedSlot = initialSlot {
    _loadActivePass();
    _fetchStationAddress();
  }

  BikeSlot? get selectedSlot => _selectedSlot;
  BookingFlow get flow => (activePass != null && activePass!.isValid)
      ? BookingFlow.hasPass
      : BookingFlow.noPass;

  bool get isLoading => bookingState.state == AsyncValueState.loading;
  String? get errorMessage => bookingState.state == AsyncValueState.error
      ? bookingState.error.toString()
      : null;
  bool get isSuccess =>
      bookingState.state == AsyncValueState.success &&
      bookingState.data == true;
  bool get successHandled => _successHandled;
  bool get errorHandled => _errorHandled;

  Future<void> _loadActivePass() async {
    try {
      activePass = await bikePassRepository.getUserActivePass(userId);
      notifyListeners();
    } catch (_) {
      // Load failure as no pass -> then the flow will route to purchase screen.
      notifyListeners();
    }
  }

  void selectSlot(BikeSlot slot) {
    if (_selectedSlot?.number == slot.number) return;
    _selectedSlot = slot;
    notifyListeners();
  }

  void markSuccessHandled() {
    _successHandled = true;
  }

  void markErrorHandled() {
    _errorHandled = true;
  }

  Future<void> _fetchStationAddress() async {
  try {
    // use OpenStreetMap's Nominatim API 
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/reverse?format=json&lat=${station.lat}&lon=${station.lng}&zoom=18&addressdetails=1&accept-language=en'
    );

    // It's good practice to identify your app in the User-Agent for Nominatim
    final response = await http.get(url, headers: {
      'User-Agent': 'BikeRentingApp_Flutter' 
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      
      // nominatim returns a field called 'display_name' or a detailed 'address' object
      final String displayName = data['display_name'] ?? "Unknown Location";
      
      // clean up the string cus it can be very long, takes only the first two part
      final parts = displayName.split(',');
      _address = parts.length >= 2 
          ? "${parts[0].trim()}, ${parts[1].trim()}" 
          : displayName;
    } else {
      _address = "Phnom Penh, Cambodia";
    }
  } catch (e) {
    debugPrint("Web Geocoding error: $e");
    _address = "Location unavailable";
  }
  notifyListeners();
}

  Future<void> confirmBooking() async {
    if (_selectedSlot == null) return;

    bookingState = AsyncValue.loading();
    _successHandled = false;
    _errorHandled = false;
    notifyListeners();

    try {
      final bool success = await bookingRepository.createBooking(
        userId: userId,
        stationId: station.id,
        slotNumber: _selectedSlot!.number,
        bikeId: _selectedSlot!.bikeId ?? '',
      );
      if (success) {
        onBookingSuccess?.call(station.id, _selectedSlot!.number);
      }
      bookingState = AsyncValue.success(success);
      _successHandled = false;
      _errorHandled = false;
    } catch (e) {
      bookingState = AsyncValue.error(e);
      _successHandled = false;
      _errorHandled = false;
    }
    notifyListeners();
  }

  Future<void> purchaseSingleTicketAndBook() async {
    if (_selectedSlot == null) return;

    bookingState = AsyncValue.loading();
    _successHandled = false;
    _errorHandled = false;
    notifyListeners();

    try {
      await bikePassRepository.purchasePass(userId, PassType.single);
      activePass = await bikePassRepository.getUserActivePass(userId);
      final bool success = await bookingRepository.createBooking(
        userId: userId,
        stationId: station.id,
        slotNumber: _selectedSlot!.number,
        bikeId: _selectedSlot!.bikeId ?? '',
      );
      if (success) {
        onBookingSuccess?.call(station.id, _selectedSlot!.number);
      }
      bookingState = AsyncValue.success(success);
      _successHandled = false;
      _errorHandled = false;
    } catch (e) {
      bookingState = AsyncValue.error(e);
      _successHandled = false;
      _errorHandled = false;
    }
    notifyListeners();
  }

  void clearError() {
    bookingState = AsyncValue.success(false);
    _successHandled = false;
    _errorHandled = false;
    notifyListeners();
  }
}
