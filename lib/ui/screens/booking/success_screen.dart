import 'package:flutter/material.dart';

class SuccessDialog extends StatelessWidget {
  final VoidCallback onBackToHome;

  const SuccessDialog({super.key, required this.onBackToHome});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Booking Success!',
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.orange.shade300, width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.check, color: Colors.orange, size: 36),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onBackToHome,
                child: const Text('Back to Map'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
