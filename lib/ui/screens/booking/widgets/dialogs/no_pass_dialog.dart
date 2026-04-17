import 'package:flutter/material.dart';

import '../../../../../../domain/models/Station/station.dart';
import '../../../../theme/theme.dart';
import 'confirm_single_ticket_dialog.dart';

class NoPassDialog extends StatelessWidget {
  final Station station;
  final BikeSlot slot;
  final VoidCallback onBuySingle;

  const NoPassDialog({
    super.key,
    required this.station,
    required this.slot,
    required this.onBuySingle,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const Icon(Icons.close, color: Colors.orange),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "You don't have a pass",
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'What would you like to do?',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 24),
            _dialogButton(
              label: 'Buy a pass',
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: navigate to pass purchase screen
              },
            ),
            const SizedBox(height: 12),
            _dialogButton(
              label: 'Buy a single pass',
              onPressed: () {
                Navigator.of(context).pop();
                showDialog(
                  context: context,
                  builder: (_) => ConfirmSingleTicketDialog(
                    station: station,
                    slot: slot,
                    onConfirm: onBuySingle,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _dialogButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: BikeAppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: Text(label),
      ),
    );
  }
}