import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:homeserve_app/services/notification_service.dart';

/// Firestore operations available to an approved, active provider.
class ProviderService {
  ProviderService._();
  static final ProviderService instance = ProviderService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw StateError('You must be signed in to manage provider data.');
    }
    return uid;
  }

  Future<void> _assertProviderAccess() async {
    final user = await _db.collection('users').doc(_uid).get();
    final data = user.data() ?? {};
    if (data['role'] != 'provider' ||
        data['providerStatus'] != 'approved' ||
        data['accountStatus'] != 'active') {
      throw StateError('Only approved, active providers can perform this action.');
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchBookingRequests() {
    return _db
        .collection('bookings')
        .where('providerId', isEqualTo: _uid)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchEmergencyRequests() {
    return _db
        .collection('bookings')
        .where('bookingType', isEqualTo: 'emergency')
        .where('status', isEqualTo: 'pending')
        .snapshots();
  }

  Future<void> updateBookingStatus(String bookingId, String status) async {
    const allowed = {'accepted', 'rejected', 'confirmed', 'in_progress', 'completed'};
    if (!allowed.contains(status)) {
      throw ArgumentError('Unsupported booking status.');
    }
    await _assertProviderAccess();
    final booking = await _db.collection('bookings').doc(bookingId).get();
    final bookingData = booking.data() ?? {};
    await booking.reference.update({
      'status': status,
      'providerUpdatedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    final customerId = bookingData['customerId']?.toString() ?? '';
    if (customerId.isNotEmpty) {
      final isCompleted = status == 'completed';
      await NotificationService.instance.create(
        userId: customerId,
        title: isCompleted ? 'Booking completed' : 'Booking $status',
        message: isCompleted
            ? 'Your service is complete. Please leave a review.'
            : 'Your provider updated your booking to $status.',
        type: isCompleted ? 'booking_completed' : 'booking_confirmed',
        relatedId: bookingId,
      );
      if (isCompleted) {
        await NotificationService.instance.create(
          userId: customerId,
          title: 'Rate your service',
          message: 'Tell others how your service experience went.',
          type: 'review_reminder',
          relatedId: bookingId,
        );
      }
    }
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchProviderProfile() {
    return _db.collection('providers').doc(_uid).snapshots();
  }

  Future<void> updateAvailability({
    required bool enabled,
    required Map<String, dynamic> schedule,
  }) async {
    await _assertProviderAccess();
    await _db.collection('providers').doc(_uid).set({
      'availability': {
        'enabled': enabled,
        'schedule': schedule,
      },
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> updateProfile({
    required String name,
    required String phone,
    required String serviceType,
    required String experience,
    required String description,
    required List<String> availableAreas,
    required String price,
    required String profileImageUrl,
  }) async {
    await _assertProviderAccess();
    await _db.collection('providers').doc(_uid).set({
      'name': name.trim(),
      'phone': phone.trim(),
      'serviceType': serviceType.trim(),
      'experience': experience.trim(),
      'description': description.trim(),
      'availableAreas': availableAreas,
      'price': price.trim(),
      'profileImageUrl': profileImageUrl.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await _db.collection('users').doc(_uid).update({
      'fullName': name.trim(),
      'phone': phone.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
