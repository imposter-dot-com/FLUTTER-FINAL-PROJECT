import '../../domain/models/Station/station.dart';

class StationDTO {
  static const String idKey = 'id';
  static const String nameKey = 'name';
  static const String latKey = 'lat';
  static const String lngKey = 'lng';
  static const String slotsKey = 'slots';

  static Station fromJson(String id, Map<String, dynamic> json) {
    assert(json[idKey] is String);
    assert(json[nameKey] is String);
    assert(json[latKey] is num);
    assert(json[lngKey] is num);
    assert(json[slotsKey] is List);

    return Station(
      id: id,
      name: json[nameKey] as String,
      lat: (json[latKey] as num).toDouble(),
      lng: (json[lngKey] as num).toDouble(),
      slots: (json[slotsKey] as List)
          .map(
            (slot) => BikeSlotDTO.fromJson(Map<String, dynamic>.from(slot as Map)),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson(Station station) => {
        idKey: station.id,
        nameKey: station.name,
        latKey: station.lat,
        lngKey: station.lng,
        slotsKey: station.slots.map((slot) => BikeSlotDTO().toJson(slot)).toList(),
      };
}

class BikeSlotDTO {
  static const String numberKey = 'number';
  static const String bikeIdKey = 'bikeId';
  static const String isOccupiedKey = 'isOccupied';

  static BikeSlot fromJson(Map<String, dynamic> json) {
    assert(json[numberKey] is int);
    assert(json[bikeIdKey] == null || json[bikeIdKey] is String);
    assert(json[isOccupiedKey] is bool);

    return BikeSlot(
      number: json[numberKey] as int,
      bikeId: json[bikeIdKey] as String?,
      isOccupied: json[isOccupiedKey] as bool,
    );
  }

  Map<String, dynamic> toJson(BikeSlot slot) => {
        numberKey: slot.number,
        bikeIdKey: slot.bikeId,
        isOccupiedKey: slot.isOccupied,
      };
}
