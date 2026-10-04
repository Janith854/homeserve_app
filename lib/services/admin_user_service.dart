import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:homeserve_app/services/notification_service.dart';

class AdminUserService {
  AdminUserService._();
  static final AdminUserService instance = AdminUserService._();

  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> _assertAdmin() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('You must be signed in.');
    final user = await _db.collection('users').doc(uid).get();
    if (user.data()?['role'] != 'admin') throw StateError('Admin access is required.');
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchCustomers() {
    return _db.collection('users').where('role', isEqualTo: 'customer').snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchApprovedProviders() {
    return _db.collection('providers').where('verificationStatus', isEqualTo: 'approved').snapshots();
  }

  Future<void> updateCustomer({
    required String userId,
    required String fullName,
    required String phone,
    required String accountStatus,
  }) async {
    await _assertAdmin();
    _validateStatus(accountStatus);
    await _db.collection('users').doc(userId).update({
      'fullName': fullName.trim(),
      'phone': phone.trim(),
      'accountStatus': accountStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await _notifyStatus(userId, accountStatus, 'customer account');
  }

  Future<void> updateProvider({
    required String providerId,
    required String name,
    required String phone,
    required String serviceType,
    required String experience,
    required String description,
    required List<String> availableAreas,
    required String accountStatus,
    String? price,
    String? profileImageUrl,
  }) async {
    await _assertAdmin();
    _validateStatus(accountStatus);
    final updates = <String, dynamic>{
      'name': name.trim(),
      'phone': phone.trim(),
      'serviceType': serviceType.trim(),
      'experience': experience.trim(),
      'description': description.trim(),
      'availableAreas': availableAreas,
      'accountStatus': accountStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (price != null) {
      updates['price'] = price.trim();
    }
    if (profileImageUrl != null) {
      updates['profileImageUrl'] = profileImageUrl.trim();
    }
    await _db.collection('providers').doc(providerId).update(updates);
    await _db.collection('users').doc(providerId).update({
      'fullName': name.trim(),
      'phone': phone.trim(),
      'accountStatus': accountStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await _notifyStatus(providerId, accountStatus, 'provider account');
  }

  void _validateStatus(String status) {
    if (status != 'active' && status != 'suspended') {
      throw ArgumentError('Invalid account status.');
    }
  }

  Future<void> _notifyStatus(String userId, String status, String subject) {
    return NotificationService.instance.create(
      userId: userId,
      title: status == 'active' ? 'Account activated' : 'Account suspended',
      message: 'Your $subject is now $status.',
      type: 'account_status',
    );
  }
}
