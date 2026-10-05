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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(
          title: const Text('Reviews & Complaints'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: widget.onBack ?? () => Navigator.of(context).maybePop(),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Reviews'),
              Tab(text: 'Complaints'),
            ],
            labelColor: AppColors.primary,
            indicatorColor: AppColors.primary,
            unselectedLabelColor: Colors.black54,
          ),
        ),
        body: TabBarView(
          children: [
            _buildReviewsTab(),
            _buildComplaintsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsTab() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: ReviewService.instance.watchReviews(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text('Could not load reviews: ${snapshot.error}'));
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final reviews = snapshot.data!.docs;
        if (reviews.isEmpty) return const Center(child: Text('No reviews found.'));

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: reviews.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) => _reviewCard(reviews[index]),
        );
      },
    );
  }

  Widget _reviewCard(QueryDocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data();
    final rating = (data['rating'] as num?)?.toInt() ?? 0;
    final comment = data['comment']?.toString() ?? 'No comment provided.';
    final date = (data['createdAt'] as Timestamp?)?.toDate().toString().split(' ')[0] ?? '';
    final bookingId = data['bookingId']?.toString() ?? '';
    final customerId = data['customerId']?.toString() ?? '';
    final providerId = data['providerId']?.toString() ?? '';

    return FutureBuilder<List<DocumentSnapshot>>(
      future: Future.wait([
        FirebaseFirestore.instance.collection('users').doc(customerId).get(),
        FirebaseFirestore.instance.collection('providers').doc(providerId).get(),
      ]),
      builder: (context, snapshot) {
        String customerName = data['customerName']?.toString() ?? 'Unknown Customer';
        String providerName = data['providerName']?.toString() ?? 'Unknown Provider';

        if (snapshot.hasData) {
          final userDoc = snapshot.data![0].data() as Map<String, dynamic>?;
          final providerDoc = snapshot.data![1].data() as Map<String, dynamic>?;
          
          if (userDoc != null && userDoc['name'] != null) {
            customerName = userDoc['name'].toString();
          }
          if (providerDoc != null && providerDoc['name'] != null) {
            providerName = providerDoc['name'].toString();
          }
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text('$customerName ➔ $providerName', style: Theme.of(context).textTheme.titleMedium),
                    ),
                    Text(date, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      size: 20,
                      color: Colors.amber,
                    );
                  }),
                ),
                const SizedBox(height: 12),
                Text('"$comment"', style: const TextStyle(fontStyle: FontStyle.italic)),
                const SizedBox(height: 12),
                Text('Booking ID: $bookingId', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildComplaintsTab() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
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
