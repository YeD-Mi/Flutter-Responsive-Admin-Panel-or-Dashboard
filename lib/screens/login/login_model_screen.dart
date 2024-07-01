import 'package:admin/models/MenusModel.dart';
import 'package:admin/screens/menus/menus_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum LoginPageState { idle, busy, error }

class LoginPageViewModel with ChangeNotifier {
  LoginPageState _state = LoginPageState.idle;
  List<MenusModel> _Menus = [];

  LoginPageState get state => _state;
  List<MenusModel> get Menus => _Menus;

  set state(LoginPageState state) {
    _state = state;
    notifyListeners();
  }

  Future<void> fetchMenus() async {
    state = LoginPageState.busy;
    try {
      MenusService menusService = MenusService();
      QuerySnapshot snapshot = await menusService.getMenus().first;
      _Menus =
          snapshot.docs.map((doc) => MenusModel.fromFirestore(doc)).toList();
      state = LoginPageState.idle;
    } catch (e) {
      state = LoginPageState.error;
    }
  }

  int get length => _Menus.length;

  MenusModel operator [](int index) => _Menus[index];

  Future<void> addMenu(MenusModel newMenu) async {
    state = LoginPageState.busy;
    try {
      MenusService menusService = MenusService();
      await menusService.addMenu(newMenu);
      _Menus.add(newMenu);
      state = LoginPageState.idle;
    } catch (e) {
      state = LoginPageState.error;
    }
  }
}
