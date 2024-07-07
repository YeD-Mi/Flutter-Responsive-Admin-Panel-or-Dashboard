import 'package:admin/constants.dart';
import 'package:flutter/material.dart';
import 'package:admin/models/UsersModel.dart';
import 'package:admin/screens/login/login_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum LoginPageState { idle, busy, error }

class LoginPageViewModel with ChangeNotifier {
  LoginPageState _state = LoginPageState.idle;
  String? _errorMessage;
  UsersModel? _currentUser;

  LoginPageState get state => _state;
  String? get errorMessage => _errorMessage;
  UsersModel? get myCurrentUser => _currentUser;

  final LoginService _loginService = LoginService();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void setState(LoginPageState state) {
    _state = state;
    notifyListeners();
  }

  void setError(String errorMessage) {
    _errorMessage = errorMessage;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    setState(LoginPageState.busy);
    try {
      _currentUser = await _loginService.connectWithMail(email, password);
      if (_currentUser != null) {
        currentUser = _currentUser;
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('currentUserID', currentUser!.userID!);
        print(currentUser!.userID!);

        setState(LoginPageState.idle);
        return true; // Giriş başarılı
      } else {
        setError('Email veya şifre hatalı!');
        setState(LoginPageState.error);
        return false; // Giriş başarısız
      }
    } catch (e) {
      setError(e.toString());
      setState(LoginPageState.error);
      return false; // Giriş başarısız
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
