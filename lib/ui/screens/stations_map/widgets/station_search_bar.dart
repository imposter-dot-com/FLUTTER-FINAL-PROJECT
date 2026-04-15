import 'package:flutter/material.dart';

class StationSearchBar extends StatelessWidget {
  const StationSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
    required this.onMenuTap,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmitted;
  final VoidCallback onMenuTap;

  @override
  Widget build(BuildContext context) {
    // Use a wide search field and a small action button on the right.
    return Row(
      children: [
        Expanded(
          child: Material(
            elevation: 3,
            borderRadius: BorderRadius.circular(18),
            color: Colors.white,
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              onSubmitted: (_) => onSubmitted(),
              decoration: const InputDecoration(
                hintText: 'Search station',
                prefixIcon: Icon(Icons.search),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 18),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Material(
          elevation: 3,
          color: Colors.white,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onMenuTap,
            customBorder: const CircleBorder(),
            child: const Padding(
              padding: EdgeInsets.all(14),
              child: Icon(Icons.more_vert),
            ),
          ),
        ),
      ],
    );
  }
}
