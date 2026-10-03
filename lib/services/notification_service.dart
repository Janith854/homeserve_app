import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get _uid {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('You must be signed in to view notifications.');
    return uid;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchNotifications() {
    return _db.collection('notifications').where('userId', isEqualTo: _uid).snapshots();
  }

  Stream<int> watchUnreadCount() {
    return watchNotifications().map(
      (snapshot) => snapshot.docs.where((doc) => doc.data()['isRead'] != true).length,
    );
  }

  Future<String> create({
    required String userId,
    required String title,
    required String message,
    required String type,
    String? relatedId,
  }) async {
    final reference = _db.collection('notifications').doc();
    await reference.set({
      'notificationId': reference.id,
      'userId': userId,
      'title': title,
      'message': message,
      'type': type,
      'relatedId': relatedId,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return reference.id;
  }

  Future<void> markAsRead(String notificationId) {
    return _db.collection('notifications').doc(notificationId).update({'isRead': true});
  }

  Future<void> markAllAsRead(QuerySnapshot<Map<String, dynamic>> snapshot) async {
    final batch = _db.batch();
    for (final doc in snapshot.docs) {
      if (doc.data()['isRead'] != true) batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }
}
