import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:homeserve_app/services/auth_service.dart';
import 'package:homeserve_app/models/user_model.dart';

class AuthNotifier extends ChangeNotifier {
  User? _user;
  UserModel? _userModel;
  bool _isLoading = true;

  User? get user => _user;
  UserModel? get userModel => _userModel;
  bool get isAuthenticated => _user != null && _userModel != null;
  bool get isLoading => _isLoading;

  AuthNotifier() {
    AuthService.instance.authStateChanges.listen((User? user) async {
      _user = user;
      if (user != null) {
        _isLoading = true;
        notifyListeners();
        _userModel = await AuthService.instance.getUserData(user.uid);
      } else {
        _userModel = null;
      }
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> logout() async {
    await AuthService.instance.logout();
  }
}

final authNotifier = AuthNotifier();
