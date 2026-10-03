import 'package:cloud_firestore/cloud_firestore.dart';

/// Maps to a Firestore document in the "providers" collection.
///
/// Expected fields:
///   providerId      – String (same as document ID)
///   userId          – String (reference to users/{userId})
///   name            – String
///   email           – String
///   phone           – String
///   serviceType     – String
///   experience      – String
///   description     – String
///   availableAreas  – `List<String>`
///   rating          – double
///   availability    - Map (availability schedule)
///   verificationStatus – String ("approved", "pending", "rejected")
///   accountStatus   – String ("active", "suspended")
///   createdAt       – Timestamp
///   updatedAt       – Timestamp
class ProviderModel {
  final String id;
  final String userId;
  final String name;
  final String email;
  final String phone;
  final String serviceType;
  final String experience;
  final String description;
  final List<String> availableAreas;
  final double rating;
  final Map<String, dynamic>? availability;
  final String profileImageUrl;
  final String verificationStatus;
  final String accountStatus;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProviderModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.serviceType,
    required this.experience,
    required this.description,
    required this.availableAreas,
    this.rating = 0.0,
    this.availability,
    this.profileImageUrl = '',
    this.verificationStatus = 'approved',
    this.accountStatus = 'active',
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProviderModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ProviderModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      serviceType: data['serviceType'] ?? '',
      experience: data['experience'] ?? '',
      description: data['description'] ?? '',
      availableAreas: List<String>.from(data['availableAreas'] ?? []),
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      availability: data['availability'] as Map<String, dynamic>?,
      profileImageUrl: data['profileImageUrl'] ?? '',
      verificationStatus: data['verificationStatus'] ?? 'approved',
      accountStatus: data['accountStatus'] ?? 'active',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'providerId': id,
      'userId': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'serviceType': serviceType,
      'experience': experience,
      'description': description,
      'availableAreas': availableAreas,
      'rating': rating,
      'availability': availability,
      'profileImageUrl': profileImageUrl,
      'verificationStatus': verificationStatus,
      'accountStatus': accountStatus,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  @override
  String toString() =>
      'ProviderModel(id: $id, name: $name, serviceType: $serviceType, '
      'verificationStatus: $verificationStatus)';

  String get category => serviceType;
  String get location => availableAreas.isEmpty ? 'Service area not provided' : availableAreas.join(', ');
  String get photoUrl => profileImageUrl;
  bool get verified => verificationStatus == 'approved';
  double get pricePerJob => 0;
}
