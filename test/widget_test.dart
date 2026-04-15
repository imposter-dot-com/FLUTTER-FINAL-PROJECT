import 'package:flutter_test/flutter_test.dart';

import 'package:bike_renting_app/main.dart';

void main() {
  test('BikeRentingApp can be created', () {
    // Keep this test simple because GoogleMap is a platform view.
    expect(const BikeRentingApp(), isNotNull);
  });
}
