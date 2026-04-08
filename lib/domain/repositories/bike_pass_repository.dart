import '../models/Pass/bike_pass.dart';

abstract class BikePassRepository {

  // to get user's active pass
  Future<BikePass?> getUserActivePass(String userId);

  // purchase a pass
  Future<void> purchasePass(String userId, PassType type);

}