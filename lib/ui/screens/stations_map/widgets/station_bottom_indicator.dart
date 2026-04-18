import 'package:flutter/material.dart';

import '../../../theme/theme.dart';

class StationBottomIndicator extends StatelessWidget {
  const StationBottomIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 102,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 54,
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
            ),
          ),
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 88,
                height: 88,
                decoration: const BoxDecoration(
                  color: BikeAppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.map,
                  color: Colors.white,
                  size: 46,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
