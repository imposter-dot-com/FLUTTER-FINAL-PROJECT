import 'package:flutter/material.dart';

import '../../../theme/theme.dart';

class StationBottomIndicator extends StatelessWidget {
  const StationBottomIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 18),
      decoration: BoxDecoration(
        color: BikeAppColors.secondary,
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (int index = 0; index < 5; index++)
            if (index == 2)
              Container(
                width: 54,
                height: 54,
                decoration: const BoxDecoration(
                  color: BikeAppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.map,
                  color: Colors.white,
                  size: 28,
                ),
              )
            else
              Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                  color: Color(0xFF9E9E9E),
                  shape: BoxShape.circle,
                ),
              ),
        ],
      ),
    );
  }
}
