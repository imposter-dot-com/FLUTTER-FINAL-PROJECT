import 'package:flutter/material.dart';

import '../../../theme/theme.dart';
import '../../../../domain/models/Station/station.dart';
import '../widgets/booking_button.dart';

class SlotCard extends StatelessWidget {
  final BikeSlot slot;
  final bool isSelected;
  final bool available;
  final bool isLoading;
  final VoidCallback? onBook;

  const SlotCard({
    super.key,
    required this.slot,
    required this.isSelected,
    required this.available,
    required this.isLoading,
    required this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? BikeAppColors.primary : Colors.grey.shade200,
          width: isSelected ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Slot #${slot.number}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: available ? Colors.green : Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        available ? 'Condition: Good' : 'Condition: Bad',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          BookingButton(
            onPressed: onBook,
            isLoading: isLoading,
            isAvailable: available,
          ),
        ],
      ),
    );
  }
}
