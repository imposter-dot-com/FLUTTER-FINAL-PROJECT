import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../domain/models/Pass/bike_pass.dart';
import '../../dtos/bike_pass_dto.dart';
import '../../../remote/firebase_constants.dart';
import 'bike_pass_repository.dart';

class BikePassRepositoryFirebase implements BikePassRepository {
  BikePass? _cachedPass;
  String? _cachedUserId;

  @override
  Future<BikePass?> getUserActivePass(String userId) async {
    // return cache if it's for the same user and still valid.
    if (_cachedUserId == userId && _cachedPass != null) {
      return _cachedPass!.isValid ? _cachedPass : null;
    }

    final uri = Uri.https(
      FirebaseConstants.databaseBaseUrl,
      '/users/$userId/pass.json',
    );
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch user pass');
    }

    if (response.body == 'null') {
      _cachedUserId = userId;
      _cachedPass = null;
      return null;
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    final pass = BikePassDTO.fromJson(data[BikePassDTO.idKey] as String, data);

    _cachedUserId = userId;
    _cachedPass = pass;

    return pass.isValid ? pass : null;
  }

  @override
  Future<void> purchasePass(String userId, PassType type) async {
    final passId = 'pass_${DateTime.now().millisecondsSinceEpoch}';

    final expiry = switch (type) {
      PassType.single => DateTime.now().add(const Duration(hours: 2)),
      PassType.day => DateTime.now().add(const Duration(days: 1)),
      PassType.monthly => DateTime.now().add(const Duration(days: 30)),
      PassType.annual => DateTime.now().add(const Duration(days: 365)),
    };

    final pass = BikePass(id: passId, type: type, expiryDate: expiry);
    final dto = BikePassDTO.toJson(pass);

    final uri = Uri.https(
      FirebaseConstants.databaseBaseUrl,
      '/users/$userId/pass.json',
    );
    final response = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(dto),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to purchase pass: ${response.body}');
    }

    // update cache immediately so next read doesn't need a network call
    _cachedUserId = userId;
    _cachedPass = pass;
  }
}
