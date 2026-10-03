import 'package:flutter/material.dart';
import 'package:homeserve_app/services/booking_service.dart';
import 'package:homeserve_app/theme/app_theme.dart';

class BookingTrackingScreen extends StatelessWidget {
  final String bookingId;
  final VoidCallback? onBack;

  const BookingTrackingScreen({
    super.key,
    required this.bookingId,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Booking Status'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack ?? () => Navigator.of(context).maybePop(),
        ),
      ),
      body: StreamBuilder(
        stream: BookingService.instance.watchBooking(bookingId),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Could not load booking: ${snapshot.error}'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final data = snapshot.data!.data();
          if (data == null) return const Center(child: Text('Booking not found.'));
          final status = data['status']?.toString() ?? 'pending';
          final steps = ['pending', 'confirmed', 'in_progress', 'completed'];
          final current = status == 'cancelled' ? -1 : steps.indexOf(status);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: ListTile(
                  title: Text(data['serviceName']?.toString() ?? 'Service'),
                  subtitle: Text('${data['date'] ?? ''} · ${data['time'] ?? ''}\n${data['address'] ?? ''}'),
                  trailing: Text(status),
                ),
              ),
              const SizedBox(height: 20),
              if (status == 'cancelled')
                const Card(child: ListTile(title: Text('Booking cancelled')))
              else
                ...steps.asMap().entries.map((entry) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: entry.key <= current ? AppColors.primary : AppColors.border,
                    child: Text('${entry.key + 1}', style: const TextStyle(color: Colors.white)),
                  ),
                  title: Text(entry.value.replaceAll('_', ' ').toUpperCase()),
                )),
              if (status != 'completed' && status != 'cancelled')
                OutlinedButton(
                  onPressed: () async {
                    try {
                      await BookingService.instance.cancelBooking(bookingId);
                    } catch (error) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$error')));
                      }
                    }
                  },
                  child: const Text('Cancel Booking'),
                ),
            ],
          );
        },
      ),
    );
  }
}
