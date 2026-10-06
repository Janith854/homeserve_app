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
              if (status == 'pending')
                OutlinedButton(
                  onPressed: () => _showCancellationDialog(context, bookingId),
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

  void _showCancellationDialog(BuildContext context, String bookingId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cancel Booking?'),
          content: const Text('Are you sure you want to cancel this booking?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Keep Booking'),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () {
                Navigator.of(context).pop();
                _showCancellationSurvey(context, bookingId);
              },
              child: const Text('Cancel Booking'),
            ),
          ],
        );
      },
    );
  }

  void _showCancellationSurvey(BuildContext context, String bookingId) {
    final reasons = [
      'I changed my mind',
      'I found another service provider',
      'The selected date/time is not convenient',
      'Price is too high',
      'I no longer need the service',
      'Booking was made by mistake',
      'Other',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.card)),
      ),
      builder: (context) {
        return _CancellationSurveySheet(bookingId: bookingId, reasons: reasons);
      },
    );
  }
}

class _CancellationSurveySheet extends StatefulWidget {
  final String bookingId;
  final List<String> reasons;

  const _CancellationSurveySheet({required this.bookingId, required this.reasons});

  @override
  State<_CancellationSurveySheet> createState() => _CancellationSurveySheetState();
}

class _CancellationSurveySheetState extends State<_CancellationSurveySheet> {
  String? _selectedReason;
  final _otherController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submit() async {
    if (_selectedReason == null) return;
    
    setState(() => _isLoading = true);
    try {
      await BookingService.instance.cancelBooking(
        widget.bookingId,
        _selectedReason!,
        note: _selectedReason == 'Other' ? _otherController.text : null,
      );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        top: AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Why are you cancelling?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.lg),
          ...widget.reasons.map((reason) {
            return ListTile(
              title: Text(reason),
              leading: Radio<String>(
                value: reason,
                groupValue: _selectedReason,
                onChanged: (val) {
                  setState(() => _selectedReason = val);
                },
              ),
              contentPadding: EdgeInsets.zero,
              onTap: () {
                setState(() => _selectedReason = reason);
              },
            );
          }),
          if (_selectedReason == 'Other') ...[
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _otherController,
              decoration: const InputDecoration(
                hintText: 'Please tell us why...',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          PrimaryButton(
            label: _isLoading ? 'Cancelling...' : 'Submit Cancellation',
            onPressed: _selectedReason == null || _isLoading ? null : _submit,
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}
