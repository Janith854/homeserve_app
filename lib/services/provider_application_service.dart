import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Handles all Firestore operations related to provider applications.
class ProviderApplicationService {
  ProviderApplicationService._();
  static final ProviderApplicationService instance = ProviderApplicationService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  /// Fetches the user's current pending provider application if it exists.
  Future<Map<String, dynamic>?> getPendingApplication() async {
    final uid = _uid;
    if (uid == null) return null;

    final existing = await _db
        .collection('providerApplications')
        .where('userId', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      return {'id': existing.docs.first.id, ...existing.docs.first.data()};
    }
    return null;
  }

  /// Submits a new provider application or updates an existing pending one.
  Future<void> submitApplication({
    required String fullName,
    required String phone,
    required String serviceType,
    required String experience,
    required String description,
    required List<String> availableAreas,
    required String price,
    String? profileImageUrl,
  }) async {
    final uid = _uid;
    if (uid == null) throw Exception('User not authenticated.');

    final existingApp = await getPendingApplication();

    final data = <String, dynamic>{
      'name': fullName,
      'phone': phone,
      'serviceType': serviceType,
      'experience': experience,
      'description': description,
      'availableAreas': availableAreas,
      'price': price,
      'profileImageUrl': profileImageUrl ?? '',
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (existingApp != null) {
      await _db.collection('providerApplications').doc(existingApp['id']).update(data);
    } else {
      data['userId'] = uid;
      data['status'] = 'pending';
      data['submittedAt'] = FieldValue.serverTimestamp();
      data['reviewedBy'] = null;
      data['reviewedAt'] = null;
      await _db.collection('providerApplications').add(data);
    }

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
