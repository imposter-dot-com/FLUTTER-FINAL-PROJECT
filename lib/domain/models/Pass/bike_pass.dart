enum PassType { day, monthly, annual, single }

class BikePass {
  final String id;
  final PassType type;
  final DateTime expiryDate;

  BikePass({required this.id, required this.type, required this.expiryDate});

  bool get isValid => expiryDate.isAfter(DateTime.now());
}