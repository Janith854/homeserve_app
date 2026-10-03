import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:homeserve_app/models/provider_application_model.dart';
import 'package:homeserve_app/models/provider_model.dart';

/// Service to handle provider verification and approval workflows.
/// 
/// Handles:
/// - Fetching pending provider applications
/// - Approving applications (multi-document update)
/// - Rejecting applications
class ProviderVerificationService {
  ProviderVerificationService._();

  static final ProviderVerificationService instance = ProviderVerificationService._();

  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  /// Fetches pending provider applications as a stream.
  /// Filters by status = "pending" and orders by submittedAt descending.
  Stream<List<ProviderApplicationModel>> watchPendingApplications() {
    return _db
        .collection('providerApplications')
        .where('status', isEqualTo: 'pending')
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map(ProviderApplicationModel.fromDoc).toList());
  }

  /// Fetches all provider applications (not filtered by status).
  Stream<List<ProviderApplicationModel>> watchAllApplications() {
    return _db
        .collection('providerApplications')
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map(ProviderApplicationModel.fromDoc).toList());
  }

  /// Approves a provider application.
  /// 
  /// Steps:
  /// 1. Update providerApplications/{applicationId}.status = "approved"
  /// 2. Set providerApplications/{applicationId}.reviewedAt = now
  /// 3. Set providerApplications/{applicationId}.reviewedBy = current admin UID
  /// 4. Update users/{userId}.role = "provider"
  /// 5. Update users/{userId}.providerStatus = "approved"
  /// 6. Update users/{userId}.updatedAt = now
  /// 7. Create/update providers/{userId} with full provider details
  Future<void> approveApplication(ProviderApplicationModel application) async {
    final adminUid = _auth.currentUser?.uid;
    if (adminUid == null) {
      throw Exception('Admin not authenticated');
    }

    try {
      await _db.runTransaction((transaction) async {
        // 1-3. Update providerApplications document
        final appDoc = _db.collection('providerApplications').doc(application.id);
        transaction.update(appDoc, {
          'status': 'approved',
          'reviewedAt': FieldValue.serverTimestamp(),
          'reviewedBy': adminUid,
        });

        // 4-6. Update users document
        final userDoc = _db.collection('users').doc(application.userId);
        transaction.update(userDoc, {
          'role': 'provider',
          'providerStatus': 'approved',
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // 7. Create/update providers document
        final providerDoc = _db.collection('providers').doc(application.userId);
        transaction.set(
          providerDoc,
          {
            'providerId': application.userId,
            'userId': application.userId,
            'name': application.name,
            'email': application.email,
            'phone': application.phone,
            'serviceType': application.serviceType,
            'experience': application.experience,
            'description': application.description,
            'availableAreas': application.availableAreas,
            'rating': 0.0,
            'verificationStatus': 'approved',
            'accountStatus': 'active',
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      });
    } catch (e) {
      throw Exception('Failed to approve application: ${e.toString()}');
    }
  }

  /// Rejects a provider application.
  /// 
  /// Steps:
  /// 1. Update providerApplications/{applicationId}.status = "rejected"
  /// 2. Set providerApplications/{applicationId}.reviewedAt = now
  /// 3. Set providerApplications/{applicationId}.reviewedBy = current admin UID
  /// 4. Update users/{userId}.providerStatus = "rejected"
  /// 5. Update users/{userId}.updatedAt = now
  /// (role remains "customer")
  Future<void> rejectApplication(ProviderApplicationModel application) async {
    final adminUid = _auth.currentUser?.uid;
    if (adminUid == null) {
      throw Exception('Admin not authenticated');
    }

    try {
      await _db.runTransaction((transaction) async {
        // 1-3. Update providerApplications document
        final appDoc = _db.collection('providerApplications').doc(application.id);
        transaction.update(appDoc, {
          'status': 'rejected',
          'reviewedAt': FieldValue.serverTimestamp(),
          'reviewedBy': adminUid,
        });

        // 4-5. Update users document
        final userDoc = _db.collection('users').doc(application.userId);
        transaction.update(userDoc, {
          'providerStatus': 'rejected',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      throw Exception('Failed to reject application: ${e.toString()}');
    }
  }
}
