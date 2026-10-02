import 'package:cloud_firestore/cloud_firestore.dart';

/// Maps to a Firestore document in the "providers" collection.
///
/// Expected fields:
///   name        – String
///   category    – String
///   rating      – num (stored as double/int)
///   verified    – bool
///   photoUrl    – String? (may be absent)
///   pricePerJob – num
///   location    – String
class ProviderModel {
  final String id;
  final String name;
  final String category;
  final double rating;
  final bool verified;
  final String? photoUrl;
  final double pricePerJob;
  final String location;

  const ProviderModel({
    required this.id,
    required this.name,
    required this.category,
    required this.rating,
    required this.verified,
    this.photoUrl,
    required this.pricePerJob,
    required this.location,
  });

  factory ProviderModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProviderModel(
      id: doc.id,
      name: (data['name'] as String?) ?? '',
      category: (data['category'] as String?) ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      verified: (data['verified'] as bool?) ?? false,
      photoUrl: data['photoUrl'] as String?,
      pricePerJob: (data['pricePerJob'] as num?)?.toDouble() ?? 0.0,
      location: (data['location'] as String?) ?? '',
    );
  }

  @override
  String toString() =>
      'ProviderModel(id: $id, name: $name, category: $category, '
      'rating: $rating, verified: $verified, pricePerJob: $pricePerJob, '
      'location: $location)';
}
