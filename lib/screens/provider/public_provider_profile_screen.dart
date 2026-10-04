import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:homeserve_app/models/provider_model.dart';
import 'package:homeserve_app/theme/app_theme.dart';

/// Read-only provider profile shown to customers.
class PublicProviderProfileScreen extends StatelessWidget {
  final String providerId;
  final VoidCallback? onBookNow;
  final VoidCallback? onBack;

  const PublicProviderProfileScreen({
    super.key,
    required this.providerId,
    this.onBookNow,
    this.onBack,
  });

  ImageProvider? _getProfileImage(String url) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return null;
    if (trimmed.startsWith('data:image')) {
      try {
        final base64Data = trimmed.split(',').last;
        return MemoryImage(base64Decode(base64Data));
      } catch (_) {
        return null;
      }
    }
    return NetworkImage(trimmed);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Provider Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack ?? () => Navigator.of(context).maybePop(),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('providers')
            .doc(providerId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Could not load provider: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.data!.exists) {
            return const Center(child: Text('Provider not found.'));
          }

          final provider = ProviderModel.fromDoc(snapshot.data!);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: provider.profileImageUrl.isEmpty
                    ? const CircleAvatar(
                        radius: 42,
                        child: Icon(Icons.build_rounded, size: 38),
                      )
                    : CircleAvatar(
                        radius: 42,
                        backgroundImage: _getProfileImage(provider.profileImageUrl),
                      ),
              ),
              const SizedBox(height: 12),
              Center(child: Text(provider.name, style: Theme.of(context).textTheme.headlineSmall)),
              const SizedBox(height: 8),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: AppColors.accent),
                    const SizedBox(width: 4),
                    Text(provider.rating.toStringAsFixed(1)),
                    if (provider.verified) ...[
                      const SizedBox(width: 12),
                      const Icon(Icons.verified, color: AppColors.primary, size: 18),
                      const SizedBox(width: 4),
                      const Text('Verified'),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _section('Service', provider.serviceType),
              _section('Price / Rate', provider.price.isNotEmpty ? provider.price : 'Contact for price'),
              _section('Experience', provider.experience),
              _section('About', provider.description),
              _section(
                'Available areas',
                provider.availableAreas.isEmpty
                    ? 'No areas listed'
                    : provider.availableAreas.join(', '),
              ),
              _section('Availability', _availabilityText(provider.availability)),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: onBookNow,
                child: const Text('View Price Estimate'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _section(String title, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(value.isEmpty ? 'Not provided' : value),
          ],
        ),
      ),
    );
  }

  String _availabilityText(Map<String, dynamic>? availability) {
    if (availability == null) return 'Availability not provided';
    final schedule = availability['schedule'];
    if (schedule is Map<String, dynamic>) {
      final days = List<String>.from(schedule['days'] ?? const <String>[]);
      final start = schedule['start']?.toString() ?? '';
      final end = schedule['end']?.toString() ?? '';
      if (days.isNotEmpty && start.isNotEmpty && end.isNotEmpty) {
        return '${days.join(', ')} · $start - $end';
      }
    }
    return availability['enabled'] == true ? 'Available for bookings' : 'Currently unavailable';
  }
}
