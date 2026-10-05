import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:homeserve_app/models/provider_model.dart';
import 'package:homeserve_app/theme/app_theme.dart';

class PriceEstimateScreen extends StatelessWidget {
  final String providerId;
  final VoidCallback? onProceedToBooking;
  final ValueChanged<ProviderModel>? onProceedWithProvider;
  final VoidCallback? onBack;

  const PriceEstimateScreen({
    super.key,
    this.providerId = '',
    this.onProceedToBooking,
    this.onProceedWithProvider,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('Price Estimate')),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('providers').doc(providerId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Could not load provider: ${snapshot.error}'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          if (!snapshot.data!.exists) return const Center(child: Text('Provider not found.'));
          final provider = ProviderModel.fromDoc(snapshot.data!);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ListTile(
                leading: provider.photoUrl.isEmpty
                    ? const CircleAvatar(child: Icon(Icons.build))
                    : CircleAvatar(backgroundImage: NetworkImage(provider.photoUrl)),
                title: Text(provider.name),
                subtitle: Text(provider.serviceType),
              ),
              const SizedBox(height: 24),
              const Text('Cost Breakdown', style: TextStyle(fontWeight: FontWeight.bold)),
              if (provider.formattedPrice.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Provider Rate'),
                      Text(provider.formattedPrice, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              const Divider(),
              _row('Estimated Total', provider.parsedPrice, bold: true),
              const SizedBox(height: 16),
              const Text('Final price may vary based on job scope.', textAlign: TextAlign.center),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () {
                  onProceedWithProvider?.call(provider);
                  if (onProceedWithProvider == null) onProceedToBooking?.call();
                },
                child: const Text('Proceed to Booking'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _row(String label, double value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: bold ? FontWeight.bold : null)),
          Text('Rs. ${value.toStringAsFixed(0)}', style: TextStyle(fontWeight: bold ? FontWeight.bold : null)),
        ],
      ),
    );
  }
}
