import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a provider application submitted by a user.
/// Maps to documents in the "providerApplications" collection.
class ProviderApplicationModel {
  final String id;
  final String userId;
  final String name;
  final String email;
  final String phone;
  final String serviceType;
  final String experience;
  final String description;
  final List<String> availableAreas;
  final String status; // "pending", "approved", "rejected"
  final DateTime submittedAt;
  final String? reviewedBy;
  final DateTime? reviewedAt;

  ProviderApplicationModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.serviceType,
    required this.experience,
    required this.description,
    required this.availableAreas,
    required this.status,
    required this.submittedAt,
    this.reviewedBy,
    this.reviewedAt,
  });

  factory ProviderApplicationModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ProviderApplicationModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      serviceType: data['serviceType'] ?? '',
      experience: data['experience'] ?? '',
      description: data['description'] ?? '',
      availableAreas: List<String>.from(data['availableAreas'] ?? []),
      status: data['status'] ?? 'pending',
      submittedAt: (data['submittedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      reviewedBy: data['reviewedBy'] as String?,
      reviewedAt: (data['reviewedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'serviceType': serviceType,
      'experience': experience,
      'description': description,
      'availableAreas': availableAreas,
      'status': status,
      'submittedAt': FieldValue.serverTimestamp(),
      'reviewedBy': reviewedBy,
      'reviewedAt': reviewedAt != null ? Timestamp.fromDate(reviewedAt!) : null,
    };
  }
}
