import 'package:admin/constants.dart';
import 'package:admin/models/UsersModel.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PersonalLocale with ChangeNotifier {
  UsersModel? _personal;

  UsersModel? get personal => _personal;

  void setPersonal(UsersModel personal) {
    _personal = personal;
    notifyListeners();
  }

  Future<String?> getCurrentUserID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    currentUserID = prefs.getString('currentUserID') ?? '';

    return currentUserID;
  }

  void setCurrentUserID(String userID) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('currentUserID', userID);
  }

  void clearCurrentUserID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('currentUserID');
  }

  void removePersonal() {
    _personal = null;
    notifyListeners();
  }
}
