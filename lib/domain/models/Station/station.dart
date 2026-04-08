class Station {
  final String id;
  final String name;
  final double lat;
  final double lng;
  final List<BikeSlot> slots;

  Station({required this.id, required this.name, required this.lat, required this.lng, required this.slots});

  int get availableBikesCount => slots.where((slot) => slot.isOccupied).length;
  bool get hasBikes => availableBikesCount > 0;
}

class BikeSlot {
  final int number;
  final String? bikeId;
  final bool isOccupied;

  BikeSlot({required this.number, this.bikeId, required this.isOccupied});
}