import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:homeserve_app/models/user_model.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Returns the current authenticated user's Firebase UID, if any.
  String? get currentUid => _auth.currentUser?.uid;

  /// Stream of Auth State changes (persisted auth).
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sign up a new customer.
  Future<UserModel> signUpCustomer({
    required String fullName,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      final uid = userCredential.user!.uid;

      final userModel = UserModel(
        uid: uid,
        fullName: fullName.trim(),
        email: email.trim(),
        phone: phone.trim(),
        role: 'customer',
        providerStatus: 'none',
        accountStatus: 'active',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _db.collection('users').doc(uid).set(userModel.toMap());
      return userModel;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('An unexpected error occurred during sign up.');
    }
  }

  /// Log in an existing user and return their UserModel data.
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      final uid = userCredential.user!.uid;

      final doc = await _db.collection('users').doc(uid).get();
      if (!doc.exists) {
        throw Exception('User record not found in database.');
      }
      return UserModel.fromDoc(doc);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('An unexpected error occurred during login.');
    }
  }

  /// Fetches the user data from Firestore for the given UID.
  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromDoc(doc);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Sign out.
  Future<void> logout() async {
    await _auth.signOut();
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'The account already exists for that email.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided for that user.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      default:
        return e.message ?? 'An unknown authentication error occurred.';
    }
  }
}
