import 'package:flutter/material.dart';
import 'package:homeserve_app/screens/booking/complaint_form_screen.dart';
import 'package:homeserve_app/services/booking_service.dart';
import 'package:homeserve_app/theme/app_theme.dart';
import 'package:homeserve_app/widgets/widgets.dart';

class BookingTrackingScreen extends StatelessWidget {
  final String bookingId;
  final VoidCallback? onBack;
  final ValueChanged<Map<String, dynamic>>? onReviewSelected;
  final ValueChanged<String>? onBookAgain;

  const BookingTrackingScreen({
    super.key,
    required this.bookingId,
    this.onBack,
    this.onReviewSelected,
    this.onBookAgain,
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
                  trailing: StatusBadge(status: status),
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
              if (status == 'completed') ...[
                FilledButton(
                  onPressed: () {
                    onReviewSelected?.call({
                      'bookingId': bookingId,
                      'providerId': data['providerId']?.toString() ?? '',
                      'providerName': data['providerName']?.toString() ?? 'Provider',
                    });
                  },
                  child: const Text('⭐  Rate & Review'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  icon: const Icon(Icons.flag_outlined, color: Colors.red),
                  label: const Text('Report a Problem', style: TextStyle(color: Colors.red)),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
                  onPressed: () {
                    final providerId = data['providerId']?.toString() ?? '';
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ComplaintFormScreen(
                          bookingId: bookingId,
                          providerId: providerId,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () {
                    final pId = data['providerId']?.toString() ?? '';
                    if (pId.isNotEmpty) {
                      onBookAgain?.call(pId);
                    }
                  },
                  child: const Text('Book Again'),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
