import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Handles all Firestore operations related to provider applications.
class ProviderApplicationService {
  ProviderApplicationService._();
  static final ProviderApplicationService instance = ProviderApplicationService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  /// Submits a new provider application to Firestore.
  /// Also updates the user's document to set providerStatus = "pending".
  Future<void> submitApplication({
    required String fullName,
    required String phone,
    required String serviceType,
    required String experience,
    required String description,
    required List<String> availableAreas,
  }) async {
    final uid = _uid;
    if (uid == null) throw Exception('User not authenticated.');

    // Check for existing pending application
    final existing = await _db
        .collection('providerApplications')
        .where('userId', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      throw Exception('You already have a pending application.');
    }

    // Save application document
    await _db.collection('providerApplications').add({
      'userId': uid,
      'name': fullName,
      'phone': phone,
      'serviceType': serviceType,
      'experience': experience,
      'description': description,
      'availableAreas': availableAreas,
      'status': 'pending',
      'submittedAt': FieldValue.serverTimestamp(),
      'reviewedBy': null,
      'reviewedAt': null,
    });

    // Update user's providerStatus to "pending"
    await _db.collection('users').doc(uid).update({
      'providerStatus': 'pending',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Returns a real-time stream of the current user's providerStatus.
  Stream<String> watchProviderStatus() {
    final uid = _uid;
    if (uid == null) return const Stream.empty();

    return _db
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return 'none';
      final data = doc.data() ?? {};
      return data['providerStatus'] as String? ?? 'none';
    });
  }
}
