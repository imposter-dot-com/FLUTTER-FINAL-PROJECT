class Station {
  final String id;
  final String name;
  final double lat;
  final double lng;
  final List<BikeSlot> slots;

  const Station({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.slots,
  });

  int get availableBikesCount => slots.where((slot) => slot.isOccupied).length;
  bool get hasBikes => availableBikesCount > 0;

  Station copyWith({
    String? id,
    String? name,
    double? lat,
    double? lng,
    List<BikeSlot>? slots,
  }) {
    return Station(
      id: id ?? this.id,
      name: name ?? this.name,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      slots: slots ?? this.slots,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Station &&
        other.id == id &&
        other.name == name &&
        other.lat == lat &&
        other.lng == lng &&
        _bikeSlotListsEqual(other.slots, slots);
  }

  @override
  int get hashCode => Object.hash(id, name, lat, lng, Object.hashAll(slots));
}

class BikeSlot {
  final int number;
  final String? bikeId;
  final bool isOccupied;

  const BikeSlot({required this.number, this.bikeId, required this.isOccupied});

  BikeSlot copyWith({int? number, String? bikeId, bool? isOccupied}) {
    return BikeSlot(
      number: number ?? this.number,
      bikeId: bikeId ?? this.bikeId,
      isOccupied: isOccupied ?? this.isOccupied,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BikeSlot &&
        other.number == number &&
        other.bikeId == bikeId &&
        other.isOccupied == isOccupied;
  }

  @override
  int get hashCode => Object.hash(number, bikeId, isOccupied);
}

bool _bikeSlotListsEqual(List<BikeSlot> left, List<BikeSlot> right) {
  if (identical(left, right)) return true;
  if (left.length != right.length) return false;

  for (int index = 0; index < left.length; index++) {
    if (left[index] != right[index]) {
      return false;
    }
  }

  return true;
}
