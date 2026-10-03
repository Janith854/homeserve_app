import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:homeserve_app/services/review_service.dart';
import 'package:homeserve_app/theme/app_theme.dart';

class AdminReviewsScreen extends StatefulWidget {
  final ValueChanged<int>? onAdminNavTap;
  final VoidCallback? onBack;

  const AdminReviewsScreen({super.key, this.onAdminNavTap, this.onBack});

  @override
  State<AdminReviewsScreen> createState() => _AdminReviewsScreenState();
}

class _AdminReviewsScreenState extends State<AdminReviewsScreen> {
  String _filter = 'all';
  final _responseController = TextEditingController();

  @override
  void dispose() {
    _responseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Reviews & Complaints'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack ?? () => Navigator.of(context).maybePop(),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: ReviewService.instance.watchComplaints(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Could not load complaints: ${snapshot.error}'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final complaints = snapshot.data!.docs.where((doc) {
            return _filter == 'all' || doc.data()['status'] == _filter;
          }).toList();
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: DropdownButtonFormField<String>(
                  initialValue: _filter,
                  decoration: const InputDecoration(labelText: 'Filter complaints'),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All')),
                    DropdownMenuItem(value: 'open', child: Text('Open')),
                    DropdownMenuItem(value: 'in_review', child: Text('In review')),
                    DropdownMenuItem(value: 'resolved', child: Text('Resolved')),
                    DropdownMenuItem(value: 'closed', child: Text('Closed')),
                  ],
                  onChanged: (value) => setState(() => _filter = value ?? 'all'),
                ),
              ),
              Expanded(
                child: complaints.isEmpty
                    ? const Center(child: Text('No complaints found.'))
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: complaints.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) => _complaintCard(complaints[index]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _complaintCard(QueryDocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data();
    final status = data['status']?.toString() ?? 'open';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(data['subject']?.toString() ?? 'Complaint', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(data['description']?.toString() ?? ''),
          const SizedBox(height: 8),
          Text('Status: $status'),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => _openComplaint(document.id, data),
            child: const Text('Open complaint'),
          ),
        ]),
      ),
    );
  }

  Future<void> _openComplaint(String id, Map<String, dynamic> data) async {
    _responseController.text = data['adminResponse']?.toString() ?? '';
    String status = data['status']?.toString() ?? 'open';
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(data['subject']?.toString() ?? 'Complaint'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(data['description']?.toString() ?? ''),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: status,
            items: const [
              DropdownMenuItem(value: 'open', child: Text('Open')),
              DropdownMenuItem(value: 'in_review', child: Text('In review')),
              DropdownMenuItem(value: 'resolved', child: Text('Resolved')),
              DropdownMenuItem(value: 'closed', child: Text('Closed')),
            ],
            onChanged: (value) => status = value ?? status,
          ),
          TextField(controller: _responseController, maxLines: 3, decoration: const InputDecoration(labelText: 'Admin response')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              await ReviewService.instance.updateComplaint(
                complaintId: id,
                status: status,
                adminResponse: _responseController.text,
              );
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
