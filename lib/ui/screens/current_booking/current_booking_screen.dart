import 'package:bike_renting_app/ui/screens/current_booking/view_model/current_booking_view_model.dart';
import 'package:bike_renting_app/ui/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CurrentBookingScreen extends StatelessWidget {
  const CurrentBookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: context.read<CurrentBookingViewModel>(),
      child: const _CurrentBookingContent(),
    );
  }
}

class _CurrentBookingContent extends StatelessWidget {
  const _CurrentBookingContent();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CurrentBookingViewModel>();
    final booking = vm.activeBooking;

    if (booking == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Navigator.of(context).canPop()) Navigator.of(context).pop();
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Current Booking'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InfoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: BikeAppColors.primary.withAlpha(20),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.location_on,
                          color: BikeAppColors.primary,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Station',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: BikeAppColors.tertiary),
                            ),
                            Text(
                              booking.stationName,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(height: 1),
                  const SizedBox(height: 20),
                  // Slot row
                  _DetailRow(
                    icon: Icons.pin_drop_outlined,
                    label: 'Bike Slot',
                    value: 'Slot #${booking.slotNumber}',
                  ),
                  const SizedBox(height: 14),
                  // Bike ID row
                  _DetailRow(
                    icon: Icons.directions_bike_outlined,
                    label: 'Bike ID',
                    value: booking.bikeId,
                  ),
                  const SizedBox(height: 14),
                  _DetailRow(
                    icon: Icons.access_time_outlined,
                    label: 'Booked at',
                    value: _formatTime(booking.bookingTime),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            if (vm.unlocked)
              _InfoCard(
                color: const Color(0xFFF0FBF4),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.green.withAlpha(30),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.lock_open, color: Colors.green),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bike Unlocked!',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            'You can now pick up your bike.',
                            style: TextStyle(color: Colors.green, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            const Spacer(),

            if (!vm.unlocked)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.lock_open_outlined),
                  label: const Text('Unlock Bike'),
                  onPressed: () => vm.unlockBike(),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  _showCancelDialog(context, vm);
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: BikeAppColors.tertiary),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BikeAppRadius.rounded,
                  ),
                ),
                child: const Text(
                  'Cancel Booking',
                  style: TextStyle(
                    color: BikeAppColors.tertiary,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '${dt.day}/${dt.month}/${dt.year}  $hour:$min';
  }

  void _showCancelDialog(BuildContext context, CurrentBookingViewModel vm) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cancel Booking?'),
        content: const Text(
          'Are you sure you want to cancel your current booking?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              vm.cancelBooking();
            },
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final Widget child;
  final Color? color;

  const _InfoCard({required this.child, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: BikeAppColors.tertiary),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: BikeAppColors.tertiary,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: BikeAppColors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
