import 'package:flutter/material.dart';
import '../../../theme/theme.dart';

class BookingButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isAvailable;

  const BookingButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
    this.isAvailable = true,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: (isLoading || !isAvailable) ? null : onPressed,
      style: ElevatedButton.styleFrom(
        // Use your predefined primary color
        backgroundColor: BikeAppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          // Using your predefined radius system
          borderRadius: BorderRadius.circular(20), 
        ),
        elevation: 0,
      ),
      child: isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Text(
              isAvailable ? 'Book now' : 'Unavailable',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }
}