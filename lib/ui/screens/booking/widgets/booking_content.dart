import 'package:bike_renting_app/domain/models/Station/station.dart';
import 'package:bike_renting_app/ui/screens/booking/success_screen.dart';
import 'package:bike_renting_app/ui/screens/booking/view_model/booking_view_model.dart';
import 'package:bike_renting_app/ui/screens/booking/widgets/dialogs/confirm_with_pass_dialog.dart';
import 'package:bike_renting_app/ui/screens/booking/widgets/dialogs/no_pass_dialog.dart';
import 'package:bike_renting_app/ui/screens/booking/widgets/slot_card.dart';
import 'package:bike_renting_app/ui/screens/booking/widgets/stat_badge.dart';
import 'package:bike_renting_app/ui/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BookingContent extends StatefulWidget {
  const BookingContent({super.key});

  @override
  State<BookingContent> createState() => _BookingContentState();
}

class _BookingContentState extends State<BookingContent> {
  bool _isShowingSuccessDialog = false;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BookingViewModel>();
    final availableSlots =
        vm.station.slots.where((s) => s.isOccupied && s.bikeId != null).toList();

    // Handle errors
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (vm.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(vm.errorMessage!),
            backgroundColor: BikeAppColors.error,
            action: SnackBarAction(
              label: 'Dismiss',
              textColor: Colors.white,
              onPressed: vm.clearError,
            ),
          ),
        );
      }

      if (vm.isSuccess && !_isShowingSuccessDialog) {
        _isShowingSuccessDialog = true;
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (_) => SuccessDialog(
            onBackToHome: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ).then((_) {
          if (!mounted) return;
          _isShowingSuccessDialog = false;
          vm.clearError();
        });
      }
    });

    return Scaffold(
      backgroundColor: BikeAppColors.background,
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Select a Bike'),
        actions: [_buildPassStatusBadge(vm)],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStationHeader(vm, context),
          const Divider(height: 1),
          Expanded(
            child: availableSlots.isEmpty
                ? const Center(
                    child: Text(
                      'No available bikes right now.',
                      style: TextStyle(color: BikeAppColors.tertiary),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: availableSlots.length,
                    separatorBuilder:
                        (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final s = availableSlots[index];

                      // Check selection against the ViewModel's state.
                      final isSelected = vm.selectedSlot?.number == s.number;

                      return SlotCard(
                        slot: s,
                        isSelected: isSelected,
                        available: true,
                        isLoading: vm.isLoading && isSelected,
                        onBook: () => _onBookTap(context, vm, s),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPassStatusBadge(BookingViewModel vm) {
    final hasPass = vm.flow == BookingFlow.hasPass;
    return Container(
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: hasPass ? BikeAppColors.primary : BikeAppColors.tertiary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        hasPass ? 'ACTIVE PASS' : 'NO PASS',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStationHeader(BookingViewModel vm, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            vm.station.name.toUpperCase(),
            style: Theme.of(
              context,
            ).textTheme.displayLarge?.copyWith(fontSize: 22),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 14,
                color: BikeAppColors.tertiary,
              ),
              const SizedBox(width: 4),
              const Text(
                'St. 6A, Phnom Penh',
                style: TextStyle(fontSize: 12, color: BikeAppColors.tertiary),
              ),
              const SizedBox(width: 8),
              _buildMapLink(context),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              StatBadge(
                icon: Icons.pedal_bike,
                value: '${vm.station.slots.length}',
                label: 'Total',
              ),
              const SizedBox(width: 16),
              StatBadge(
                icon: Icons.local_parking,
                value: '${vm.station.slots.where((s) => !s.isOccupied).length}',
                label: 'Parking',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMapLink(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          border: Border.all(color: BikeAppColors.primary),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Row(
          children: [
            Icon(Icons.map_outlined, size: 12, color: BikeAppColors.primary),
            SizedBox(width: 2),
            Text(
              'Map',
              style: TextStyle(fontSize: 11, color: BikeAppColors.primary),
            ),
          ],
        ),
      ),
    );
  }

  void _onBookTap(BuildContext context, BookingViewModel vm, BikeSlot slot) {
    // Update the VM so it knows which slot we are attempting to book
    vm.selectSlot(slot);

    if (vm.flow == BookingFlow.hasPass) {
      showDialog(
        context: context,
        builder: (_) => ConfirmWithPassDialog(
          station: vm.station,
          slot: slot,
          onConfirm: vm.confirmBooking,
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => NoPassDialog(
          station: vm.station,
          slot: slot,
          onBuySingle: vm.purchaseSingleTicketAndBook,
        ),
      );
    }
  }
}
