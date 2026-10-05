import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:homeserve_app/screens/booking/complaint_form_screen.dart';
import 'package:homeserve_app/services/booking_service.dart';
import 'package:homeserve_app/theme/app_theme.dart';

class ServiceHistoryScreen extends StatefulWidget {
  final ValueChanged<String>? onBookingSelected;
  final ValueChanged<Map<String, dynamic>>? onReviewSelected;
  final VoidCallback? onBack;

  const ServiceHistoryScreen({super.key, this.onBookingSelected, this.onReviewSelected, this.onBack});

  @override
  State<ServiceHistoryScreen> createState() => _ServiceHistoryScreenState();
}

class _ServiceHistoryScreenState extends State<ServiceHistoryScreen> {
  int _tab = 0;
  final _tabs = const ['Upcoming', 'Completed', 'Cancelled'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Service History'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack ?? () => Navigator.of(context).maybePop(),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: BookingService.instance.watchCustomerBookings(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Could not load history: ${snapshot.error}'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final bookings = snapshot.data!.docs.where((doc) {
            final status = doc.data()['status']?.toString() ?? 'pending';
            if (_tab == 1) return status == 'completed';
            if (_tab == 2) return status == 'cancelled';
            return status != 'completed' && status != 'cancelled';
          }).toList();
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: SegmentedButton<int>(
                  segments: [
                    for (var i = 0; i < _tabs.length; i++)
                      ButtonSegment(value: i, label: Text(_tabs[i])),
                  ],
                  selected: {_tab},
                  onSelectionChanged: (value) => setState(() => _tab = value.first),
                ),
              ),
              Expanded(
                child: bookings.isEmpty
                    ? const Center(child: Text('No bookings in this section.'))
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: bookings.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final doc = bookings[index];
                          final data = doc.data();
                          return Card(
                            child: ListTile(
                              title: Text(data['serviceName']?.toString() ?? 'Service'),
                              subtitle: Text('${data['date'] ?? ''} · ${data['time'] ?? ''}\n${data['address'] ?? ''}'),
                              trailing: _tab == 1
                                  ? Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.star, color: Colors.amber),
                                          tooltip: 'Leave a Review',
                                          onPressed: () => widget.onReviewSelected?.call({
                                            'bookingId': doc.id,
                                            'providerId': data['providerId']?.toString() ?? '',
                                            'providerName': data['providerName']?.toString() ?? 'Provider',
                                          }),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.flag_outlined, color: Colors.red),
                                          tooltip: 'Report a Problem',
                                          onPressed: () => Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) => ComplaintFormScreen(
                                                bookingId: doc.id,
                                                providerId: data['providerId']?.toString() ?? '',
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Text(data['status']?.toString() ?? 'pending'),
                              onTap: () => widget.onBookingSelected?.call(doc.id),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
