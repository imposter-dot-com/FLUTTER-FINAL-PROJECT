import '../../../domain/models/Pass/bike_pass.dart';
import 'bike_pass_repository.dart';

class BikePassRepositoryMock implements BikePassRepository {
  final Map<String, BikePass> _passesByUser = {};

  @override
  Future<BikePass?> getUserActivePass(String userId) async {
    final BikePass? pass = _passesByUser[userId];
    if (pass == null) return null;
    return pass.isValid ? pass : null;
  }

  @override
  Future<void> purchasePass(String userId, PassType type) async {
    final DateTime now = DateTime.now();
    final DateTime expiry = switch (type) {
      PassType.single => now.add(const Duration(hours: 2)),
      PassType.day => now.add(const Duration(days: 1)),
      PassType.monthly => now.add(const Duration(days: 30)),
      PassType.annual => now.add(const Duration(days: 365)),
    };

    _passesByUser[userId] = BikePass(
      id: 'mock_pass_${now.millisecondsSinceEpoch}',
      type: type,
      expiryDate: expiry,
    );
  }
}
