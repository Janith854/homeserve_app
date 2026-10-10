import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:homeserve_app/services/provider_service.dart';
import 'package:homeserve_app/theme/app_theme.dart';
import 'package:homeserve_app/widgets/widgets.dart';

class ProviderBookingRequestsScreen extends StatelessWidget {
  final ValueChanged<int>? onProviderNavTap;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onMenuTap;

  const ProviderBookingRequestsScreen({
    super.key,
    this.onProviderNavTap,
    this.onNotificationTap,
    this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('Booking Requests')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: ProviderService.instance.watchBookingRequests(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Could not load requests: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: ProviderService.instance.watchEmergencyRequests(),
            builder: (context, emergencySnapshot) {
              if (emergencySnapshot.hasError) {
                return Center(child: Text('Could not load emergency requests: ${emergencySnapshot.error}'));
              }
              if (!emergencySnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final bookings = [
                ...snapshot.data!.docs,
                ...emergencySnapshot.data!.docs,
              ].where((doc) {
                final status = doc.data()['status']?.toString() ?? 'pending';
                return status != 'cancelled';
              }).toList();
              
              if (bookings.isEmpty) {
                return const Center(child: Text('No booking requests yet.'));
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: bookings.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) => _BookingCard(document: bookings[index]),
              );
            },
          );
        },
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> document;

  const _BookingCard({required this.document});

  @override
  Widget build(BuildContext context) {
    final data = document.data();
    final status = (data['status'] ?? 'pending').toString();
    final customer = (data['customerName'] ?? data['customer'] ?? 'Customer').toString();
    final service = (data['serviceType'] ?? data['service'] ?? 'Service request').toString();
    final isEmergency = data['bookingType'] == 'emergency';
    final date = (data['scheduledAt'] ?? data['date'] ?? '').toString();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(customer, style: Theme.of(context).textTheme.titleMedium),
              StatusBadge(status: status),
            ],
          ),
          const SizedBox(height: 6),
          Row(children: [
            Expanded(child: Text(service)),
            if (isEmergency)
              const Chip(
                label: Text('EMERGENCY'),
                backgroundColor: Colors.red,
                labelStyle: TextStyle(color: Colors.white),
              ),
          ]),
          if (date.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(date, style: Theme.of(context).textTheme.bodySmall),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              if (status == 'pending')
                FilledButton(
                  onPressed: () => ProviderService.instance
                      .updateBookingStatus(document.id, 'confirmed'),
                  child: const Text('Accept'),
                ),
              if (status == 'pending')
                OutlinedButton(
                  onPressed: () => ProviderService.instance
                      .updateBookingStatus(document.id, 'rejected'),
                  child: const Text('Reject'),
                ),
              if (status == 'confirmed')
                OutlinedButton(
                  onPressed: () => ProviderService.instance
                      .updateBookingStatus(document.id, 'in_progress'),
                  child: const Text('Start job'),
                ),
              if (status == 'in_progress' || status == 'in progress')
                FilledButton(
                  onPressed: () => ProviderService.instance
                      .updateBookingStatus(document.id, 'completed'),
                  child: const Text('Complete'),
                ),
            ],
          ),
        ]),
      ),
    );
  }
}
