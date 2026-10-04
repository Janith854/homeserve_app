import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:homeserve_app/services/provider_service.dart';
import 'package:homeserve_app/theme/app_theme.dart';

class ProviderAvailabilityScreen extends StatefulWidget {
  final VoidCallback? onSaveChanges;
  final ValueChanged<int>? onProviderNavTap;
  final VoidCallback? onBack;

  const ProviderAvailabilityScreen({
    super.key,
    this.onSaveChanges,
    this.onProviderNavTap,
    this.onBack,
  });

  @override
  State<ProviderAvailabilityScreen> createState() => _ProviderAvailabilityScreenState();
}

class _ProviderAvailabilityScreenState extends State<ProviderAvailabilityScreen> {
  final _startController = TextEditingController();
  final _endController = TextEditingController();
  final _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final Set<String> _selectedDays = {};
  bool _enabled = false;
  bool _loaded = false;
  bool _saving = false;

  @override
  void dispose() {
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('Availability')),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: ProviderService.instance.watchProviderProfile(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Could not load availability: ${snapshot.error}'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          _load(snapshot.data!.data()?['availability'] as Map<String, dynamic>?);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SwitchListTile(
                title: const Text('Available for bookings'),
                subtitle: const Text('Disable to pause new booking requests.'),
                value: _enabled,
                onChanged: (value) => setState(() => _enabled = value),
              ),
              const SizedBox(height: 16),
              const Text('Working days'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _days.map((day) => FilterChip(
                  label: Text(day),
                  selected: _selectedDays.contains(day),
                  onSelected: (selected) => setState(() {
                    selected ? _selectedDays.add(day) : _selectedDays.remove(day);
                  }),
                )).toList(),
              ),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: TextField(controller: _startController, decoration: const InputDecoration(labelText: 'Start time'))),
                const SizedBox(width: 12),
                Expanded(child: TextField(controller: _endController, decoration: const InputDecoration(labelText: 'End time'))),
              ]),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: Text(_saving ? 'Saving...' : 'Save availability'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _load(Map<String, dynamic>? availability) {
    if (_loaded || availability == null) {
      _loaded = true;
      return;
    }
    final schedule = availability['schedule'];
    if (schedule is Map<String, dynamic>) {
      _selectedDays.addAll(List<String>.from(schedule['days'] ?? const <String>[]));
      _startController.text = schedule['start']?.toString() ?? '';
      _endController.text = schedule['end']?.toString() ?? '';
    }
    _enabled = availability['enabled'] == true;
    _loaded = true;
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ProviderService.instance.updateAvailability(
        enabled: _enabled,
        schedule: {
          'days': _selectedDays.toList(),
          'start': _startController.text.trim(),
          'end': _endController.text.trim(),
        },
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Availability saved.')));
        widget.onSaveChanges?.call();
      }
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not save availability: $error')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
