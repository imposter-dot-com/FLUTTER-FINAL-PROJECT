import '../../../domain/models/Pass/bike_pass.dart';

abstract class BikePassRepository {
  Future<BikePass?> getUserActivePass(String userId);

  Future<void> purchasePass(String userId, PassType type);
}
