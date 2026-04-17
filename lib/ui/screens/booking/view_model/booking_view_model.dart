import 'package:flutter/material.dart';

import '../../../../../data/repositories/bike_pass/bike_pass_repository.dart';
import '../../../../../data/repositories/booking/booking_repository.dart';
import '../../../../../domain/models/Pass/bike_pass.dart';
import '../../../../../domain/models/Station/station.dart';
import '../../../utils/async_value.dart';

enum BookingFlow { hasPass, noPass }

class BookingViewModel extends ChangeNotifier{
  final BikePassRepository bikePassRepository;
  final BookingRepository bookingRepository;
  final String userId;
  final Station station;
  final void Function(String stationId, int slotNumber)? onBookingSuccess;
  BikeSlot? _selectedSlot;


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
  }

  BikeSlot? get selectedSlot => _selectedSlot;
  BookingFlow get flow => (activePass != null && activePass!.isValid) ? BookingFlow.hasPass : BookingFlow.noPass;

  bool get isLoading => bookingState.state == AsyncValueState.loading;
  String? get errorMessage => bookingState.state == AsyncValueState.error ? bookingState.error.toString() : null;
  bool get isSuccess => bookingState.state == AsyncValueState.success && bookingState.data == true;

  Future<void> _loadActivePass() async{
    try{
      activePass = await bikePassRepository.getUserActivePass(userId);
      notifyListeners(); 
    } catch (_) {
      // load failure as no pass --> then the flow will route to purchase screen 
      notifyListeners();
    }
  }

  void selectSlot(BikeSlot slot){
    if(_selectedSlot?.number == slot.number) return;
    _selectedSlot = slot;
    notifyListeners();
  }

  Future<void> confirmBooking() async{
    if(_selectedSlot == null) return;

    bookingState = AsyncValue.loading();
    notifyListeners();

    try{
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
    } catch (e) {
      bookingState = AsyncValue.error(e);
    }
    notifyListeners();
  }

  Future<void> purchaseSingleTicketAndBook() async{
    if(_selectedSlot == null) return;

    bookingState = AsyncValue.loading();
    notifyListeners();

    try{
      await bikePassRepository.purchasePass(userId, PassType.single);
      activePass = await bikePassRepository.getUserActivePass(userId);
      final bool success = await bookingRepository.createBooking(userId: userId, stationId: station.id, slotNumber: _selectedSlot!.number, bikeId: _selectedSlot!.bikeId ?? '',);
      if (success) {
        onBookingSuccess?.call(station.id, _selectedSlot!.number);
      }
      bookingState = AsyncValue.success(success);
    }catch(e){
      bookingState = AsyncValue.error(e);
    }
    notifyListeners();
  }

  void clearError(){
    bookingState = AsyncValue.success(false);
    notifyListeners();
  }
}
