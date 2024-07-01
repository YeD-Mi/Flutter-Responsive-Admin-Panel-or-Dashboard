import 'package:admin/models/MenusModel.dart';
import 'package:admin/screens/menus/menus_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum MenusPageState { idle, busy, error }

class MenusPageViewModel with ChangeNotifier {
  MenusPageState _state = MenusPageState.idle;
  List<MenusModel> _Menus = [];

  MenusPageState get state => _state;
  List<MenusModel> get Menus => _Menus;

  set state(MenusPageState state) {
    _state = state;
    notifyListeners();
  }

  Future<void> fetchMenus() async {
    state = MenusPageState.busy;
    try {
      MenusService menusService = MenusService();
      QuerySnapshot snapshot = await menusService.getMenus().first;
      _Menus =
          snapshot.docs.map((doc) => MenusModel.fromFirestore(doc)).toList();
      state = MenusPageState.idle;
    } catch (e) {
      state = MenusPageState.error;
    }
  }

  int get length => _Menus.length;

  MenusModel operator [](int index) => _Menus[index];

  Future<void> addMenu(MenusModel newMenu) async {
    state = MenusPageState.busy;
    try {
      MenusService menusService = MenusService();
      await menusService.addMenu(newMenu);
      _Menus.add(newMenu);
      state = MenusPageState.idle;
    } catch (e) {
      state = MenusPageState.error;
    }
  }
}
