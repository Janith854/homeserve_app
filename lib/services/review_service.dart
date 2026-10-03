import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReviewService {
  ReviewService._();
  static final ReviewService instance = ReviewService._();

  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> submitReview({
    required String bookingId,
    required String providerId,
    required int rating,
    required String comment,
  }) async {
    final customerId = _auth.currentUser?.uid;
    if (customerId == null) throw StateError('You must be signed in to review.');
    if (rating < 1 || rating > 5) throw ArgumentError('Rating must be between 1 and 5.');

    final bookingRef = _db.collection('bookings').doc(bookingId);
    final reviewRef = _db.collection('reviews').doc(bookingId);
    final providerRef = _db.collection('providers').doc(providerId);

    await _db.runTransaction((transaction) async {
      final booking = await transaction.get(bookingRef);
      final bookingData = booking.data() as Map<String, dynamic>?;
      if (!booking.exists ||
          bookingData?['customerId'] != customerId ||
          bookingData?['providerId'] != providerId ||
          bookingData?['status'] != 'completed') {
        throw StateError('Only completed bookings can be reviewed.');
      }

      final existing = await transaction.get(reviewRef);
      if (existing.exists) {
        throw StateError('This booking has already been reviewed.');
      }

      final provider = await transaction.get(providerRef);
      final providerData = provider.data() as Map<String, dynamic>? ?? {};
      final oldCount = (providerData['reviewCount'] as num?)?.toInt() ?? 0;
      final oldRating = (providerData['rating'] as num?)?.toDouble() ?? 0;
      final newCount = oldCount + 1;
      final newRating = ((oldRating * oldCount) + rating) / newCount;

      transaction.set(reviewRef, {
        'reviewId': reviewRef.id,
        'bookingId': bookingId,
        'customerId': customerId,
        'providerId': providerId,
        'rating': rating,
        'comment': comment.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      transaction.set(providerRef, {
        'rating': newRating,
        'reviewCount': newCount,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchComplaints() {
    return _db.collection('complaints').snapshots();
  }

  Future<String> createComplaint({
    required String providerId,
    required String bookingId,
    required String subject,
    required String description,
  }) async {
    final customerId = _auth.currentUser?.uid;
    if (customerId == null) throw StateError('You must be signed in to submit a complaint.');
    final reference = _db.collection('complaints').doc();
    await reference.set({
      'complaintId': reference.id,
      'customerId': customerId,
      'providerId': providerId,
      'bookingId': bookingId,
      'subject': subject.trim(),
      'description': description.trim(),
      'status': 'open',
      'adminResponse': '',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return reference.id;
  }

  Future<void> updateComplaint({
    required String complaintId,
    required String status,
    required String adminResponse,
  }) async {
    const statuses = {'open', 'in_review', 'resolved', 'closed'};
    if (!statuses.contains(status)) throw ArgumentError('Invalid complaint status.');
    await _db.collection('complaints').doc(complaintId).update({
      'status': status,
      'adminResponse': adminResponse.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
