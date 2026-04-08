  class Booking {
    final String id;
    final String stationName;
    final int slotNumber;
    final DateTime bookingTime;
    final String bikeId;

    Booking({required this.id, required this.stationName, required this.slotNumber, required this.bookingTime, required this.bikeId});
  }