import '../../domain/models/Pass/bike_pass.dart';

class BikePassDTO {
  static const String idKey = 'id';
  static const String typeKey = 'type';
  static const String expiryKey = 'expiryDate';

  static BikePass fromJson(String id, Map<String, dynamic> json) {
    assert(json[idKey] is String);
    assert(json[typeKey] is String);
    assert(json[expiryKey] is String);

    final typeString = json[typeKey] as String;
    return BikePass(
      id: id,
      type: PassType.values.firstWhere((value) => value.name == typeString),
      expiryDate: DateTime.parse(json[expiryKey] as String),
    );
  }

  Map<String, dynamic> toJson(BikePass pass) => {
        idKey: pass.id,
        typeKey: pass.type.name,
        expiryKey: pass.expiryDate.toIso8601String(),
      };
}
