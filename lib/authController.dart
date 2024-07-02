import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends ChangeNotifier {
  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;

  AuthController() {
    _loadLoginStatus();
  }

  void login() async {
    _isLoggedIn = true;
    notifyListeners();
    _saveLoginStatus();
  }

  void logout() async {
    _isLoggedIn = false;
    notifyListeners();
    _saveLoginStatus();
  }

  Future<void> _loadLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    notifyListeners();
  }

  Future<void> _saveLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', _isLoggedIn);
  }
}
