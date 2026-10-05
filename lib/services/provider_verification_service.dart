import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:homeserve_app/models/provider_application_model.dart';
import 'package:homeserve_app/services/notification_service.dart';

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
            'price': application.price,
            'profileImageUrl': application.profileImageUrl,
            'rating': 0.0,
            'reviewCount': 0,
            'verificationStatus': 'approved',
            'accountStatus': 'active',
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      });
      await NotificationService.instance.create(
        userId: application.userId,
        title: 'Provider application approved',
        message: 'Your provider application has been approved.',
        type: 'provider_application',
        relatedId: application.id,
      );
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
      await NotificationService.instance.create(
        userId: application.userId,
        title: 'Provider application rejected',
        message: 'Your provider application was not approved.',
        type: 'provider_application',
        relatedId: application.id,
      );
    } catch (e) {
      throw Exception('Failed to reject application: ${e.toString()}');
    }
  }

  Future<String> submitApplication({
      required String name,
      required String email,
      required String phone,
      required String serviceType,
      required String experience,
      required String description,
      required List<String> availableAreas,
    }) async {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw StateError('You must be signed in to apply.');
      final reference = _db.collection('providerApplications').doc();
      await reference.set({
        'applicationId': reference.id,
        'userId': userId,
        'name': name.trim(),
        'email': email.trim(),
        'phone': phone.trim(),
        'serviceType': serviceType.trim(),
        'experience': experience.trim(),
        'description': description.trim(),
        'availableAreas': availableAreas,
        'status': 'pending',
        'submittedAt': FieldValue.serverTimestamp(),
      });
      await NotificationService.instance.create(
        userId: userId,
        title: 'Provider application submitted',
        message: 'Your provider application is waiting for admin review.',
        type: 'provider_application',
        relatedId: reference.id,
      );
      final admins = await _db.collection('users').where('role', isEqualTo: 'admin').get();
      for (final admin in admins.docs) {
        await NotificationService.instance.create(
          userId: admin.id,
          title: 'New provider application',
          message: '$name submitted a provider application for review.',
          type: 'provider_application',
          relatedId: reference.id,
        );
      }
      return reference.id;
  }
}
