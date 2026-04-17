import 'package:flutter/material.dart';

import '../../../../../../domain/models/Station/station.dart';
import '../../../../theme/theme.dart';

class ConfirmSingleTicketDialog extends StatelessWidget {
  final Station station;
  final BikeSlot slot;
  final VoidCallback onConfirm;

  const ConfirmSingleTicketDialog({
    super.key,
    required this.station,
    required this.slot,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Confirm Booking',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Bike Slot #${slot.number} · ${station.name}',
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const Divider(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Single pass',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                Text('x1', style: TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Ride Cost', style: TextStyle(color: Colors.grey)),
                Text('\$1.50', style: TextStyle(color: Colors.grey)),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Total Due',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text('\$1.50',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onConfirm();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: BikeAppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Confirm & Pay'),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Reserved for 5:00 minutes',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel',
                    style: TextStyle(color: Colors.grey)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}