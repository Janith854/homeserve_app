import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:homeserve_app/services/notification_service.dart';

class BookingService {
  BookingService._();
  static final BookingService instance = BookingService._();

  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<String> createBooking({
    required String providerId,
    required String serviceId,
    required String serviceName,
    required String date,
    required String time,
    required String address,
    required double price,
    String specialRequest = '',
    String bookingType = 'normal',
  }) async {
    final customerId = _auth.currentUser?.uid;
    if (customerId == null) {
      throw StateError('You must be signed in to create a booking.');
    }

    final reference = _db.collection('bookings').doc();
    final data = {
      'bookingId': reference.id,
      'customerId': customerId,
      'providerId': providerId,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'date': date,
      'time': time,
      'address': address.trim(),
      'specialRequest': specialRequest.trim(),
      'price': price,
      'bookingType': bookingType,
      'paymentStatus': 'pending',
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    await reference.set(data);
    await NotificationService.instance.create(
      userId: customerId,
      title: 'Booking created',
      message: '$serviceName booking request was submitted.',
      type: 'booking_created',
      relatedId: reference.id,
    );
    if (providerId.isNotEmpty) {
      await NotificationService.instance.create(
        userId: providerId,
        title: 'New booking request',
        message: 'A customer requested $serviceName.',
        type: 'booking_created',
        relatedId: reference.id,
      );
    }
    return reference.id;
  }

  Future<String> createEmergencyBooking({
    required String serviceName,
    required String issueDescription,
    required String address,
  }) {
    return createBooking(
      providerId: '',
      serviceId: serviceName.toLowerCase().replaceAll(' ', '_'),
      serviceName: '$serviceName emergency: $issueDescription',
      date: DateTime.now().toIso8601String().split('T').first,
      time: _formatTime(DateTime.now()),
      address: address,
      price: 0,
      specialRequest: issueDescription,
      bookingType: 'emergency',
    );
  }

  Future<void> updateBookingDetails({
    required String bookingId,
    required String date,
    required String time,
    required String address,
    required String specialRequest,
  }) async {
    final customerId = _auth.currentUser?.uid;
    if (customerId == null) {
      throw StateError('You must be signed in to update a booking.');
    }
    final booking = await _db.collection('bookings').doc(bookingId).get();
    if (!booking.exists) throw StateError('Booking not found.');
    if (booking.data()?['customerId'] != customerId) {
      throw StateError('You can only update your own booking.');
    }
    
    final status = booking.data()?['status'];
    if (status != 'pending') {
      throw StateError('Only pending bookings can be edited.');
    }

    await booking.reference.update({
      'date': date,
      'time': time,
      'address': address.trim(),
      'specialRequest': specialRequest.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  String _formatTime(DateTime value) {
    final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute ${value.hour >= 12 ? 'PM' : 'AM'}';
  }

  Future<void> markPaymentCompleted(String bookingId) async {
    final booking = await _db.collection('bookings').doc(bookingId).get();
    final data = booking.data() ?? {};
    await booking.reference.update({
      'paymentStatus': 'paid',
      'status': 'confirmed',
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await NotificationService.instance.create(
      userId: data['customerId']?.toString() ?? _auth.currentUser!.uid,
      title: 'Booking confirmed',
      message: 'Your payment was successful and booking is confirmed.',
      type: 'booking_confirmed',
      relatedId: bookingId,
    );
    final providerId = data['providerId']?.toString() ?? '';
    if (providerId.isNotEmpty) {
      await NotificationService.instance.create(
        userId: providerId,
        title: 'Booking confirmed',
        message: 'A booking has been paid and confirmed.',
        type: 'booking_confirmed',
        relatedId: bookingId,
      );
    }
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchBooking(String bookingId) {
    return _db.collection('bookings').doc(bookingId).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchCustomerBookings() {
    final customerId = _auth.currentUser?.uid;
    if (customerId == null) {
      throw StateError('You must be signed in to view booking history.');
    }
    return _db
        .collection('bookings')
        .where('customerId', isEqualTo: customerId)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchBookingsForProvider(String providerId) {
    final customerId = _auth.currentUser?.uid;
    if (customerId == null) {
      throw StateError('You must be signed in to view bookings.');
    }
    return _db
        .collection('bookings')
        .where('customerId', isEqualTo: customerId)
        .where('providerId', isEqualTo: providerId)
        .snapshots();
  }

  Future<void> cancelBooking(String bookingId) async {
    final customerId = _auth.currentUser?.uid;
    if (customerId == null) throw StateError('You must be signed in.');
    final booking = await _db.collection('bookings').doc(bookingId).get();
    if (booking.data()?['customerId'] != customerId) {
      throw StateError('You can only cancel your own booking.');
    }
    final status = booking.data()?['status'];
    if (status == 'completed' || status == 'cancelled') {
      throw StateError('This booking cannot be cancelled.');
    }
    await booking.reference.update({
      'status': 'cancelled',
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await NotificationService.instance.create(
      userId: customerId,
      title: 'Booking cancelled',
      message: 'Your booking has been cancelled.',
      type: 'booking_cancelled',
      relatedId: bookingId,
    );
    final providerId = booking.data()?['providerId']?.toString() ?? '';
    if (providerId.isNotEmpty) {
      await NotificationService.instance.create(
        userId: providerId,
        title: 'Booking cancelled',
        message: 'A customer cancelled a booking request.',
        type: 'booking_cancelled',
        relatedId: bookingId,
      );
    }
  }

  Future<void> updateBookingStatus(String bookingId, String newStatus) async {
    final booking = await _db.collection('bookings').doc(bookingId).get();
    final data = booking.data();
    if (data == null) return;

    await booking.reference.update({
      'status': newStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    final customerId = data['customerId']?.toString();
    if (customerId == null || customerId.isEmpty) return;

    String title = '';
    String message = '';
    String type = '';

    switch (newStatus.toLowerCase()) {
      case 'confirmed':
        title = 'Booking Confirmed';
        message = 'Your booking has been accepted by the provider.';
        type = 'booking_confirmed';
        break;
      case 'in_progress':
      case 'in progress':
        title = 'Service Started';
        message = 'Your service is now in progress.';
        type = 'service_started';
        break;
      case 'completed':
        title = 'Service Completed';
        message = 'Your service has been completed.';
        type = 'service_completed';
        break;
      case 'rejected':
        title = 'Booking Rejected';
        message = 'Your booking request was rejected.';
        type = 'booking_rejected';
        break;
      default:
        return; // No notification for other generic updates
    }

    await NotificationService.instance.create(
      userId: customerId,
      title: title,
      message: message,
      type: type,
      relatedId: bookingId,
    );
  }
}
