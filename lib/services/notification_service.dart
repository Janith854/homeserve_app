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

  /// Watch notifications for the currently signed-in user.
  Stream<QuerySnapshot<Map<String, dynamic>>> watchNotifications() {
    return _db.collection('notifications').where('userId', isEqualTo: _uid).snapshots();
  }

  /// Unread count for the current user.
  Stream<int> watchUnreadCount() {
    return watchNotifications().map(
      (snapshot) => snapshot.docs.where((doc) => doc.data()['isRead'] != true).length,
    );
  }

  /// Create a notification for a specific user.
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

  /// Send a notification to all admin users.
  Future<void> notifyAdmins({
    required String title,
    required String message,
    required String type,
    String? relatedId,
  }) async {
    final admins = await _db.collection('users').where('role', isEqualTo: 'admin').get();
    for (final admin in admins.docs) {
      await create(
        userId: admin.id,
        title: title,
        message: message,
        type: type,
        relatedId: relatedId,
      );
    }
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

  /// Delete a single notification (only if it belongs to the current user).
  Future<void> deleteNotification(String notificationId) async {
    final doc = await _db.collection('notifications').doc(notificationId).get();
    if (doc.exists && doc.data()?['userId'] == _uid) {
      await doc.reference.delete();
    }
  }

  /// Delete multiple notifications by ID (only those belonging to the current user).
  Future<void> deleteMultiple(List<String> notificationIds) async {
    if (notificationIds.isEmpty) return;
    final batch = _db.batch();
    for (final id in notificationIds) {
      final docRef = _db.collection('notifications').doc(id);
      final docSnap = await docRef.get();
      if (docSnap.exists && docSnap.data()?['userId'] == _uid) {
        batch.delete(docRef);
      }
    }
    await batch.commit();
  }

  /// Clear all notifications for the currently signed-in user.
  Future<void> clearAll() async {
    final snapshot = await _db
        .collection('notifications')
        .where('userId', isEqualTo: _uid)
        .get();
    if (snapshot.docs.isEmpty) return;
    final batch = _db.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
