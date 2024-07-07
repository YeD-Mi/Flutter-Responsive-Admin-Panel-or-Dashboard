import 'package:admin/constants.dart';
import 'package:admin/models/CategoriesModel.dart';
import 'package:admin/models/MenusModel.dart';
import 'package:admin/screens/categories/categories_service.dart';
import 'package:admin/screens/menus/menus_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum MenusPageState { idle, busy, error }

class MenusPageViewModel with ChangeNotifier {
  MenusPageState _state = MenusPageState.idle;
  List<MenusModel> _menus = [];
  List<CategoriesModel> _categories = [];

  MenusPageState get state => _state;
  List<MenusModel> get menus => _menus;
  List<CategoriesModel> get categories => _categories;

  set state(MenusPageState state) {
    _state = state;
    notifyListeners();
  }

  Future<void> fetchMenus() async {
    state = MenusPageState.busy;
    try {
      MenusService menusService = MenusService();
      QuerySnapshot snapshot = await menusService.getMenus().first;
      _menus =
          snapshot.docs.map((doc) => MenusModel.fromFirestore(doc)).toList();
      state = MenusPageState.idle;
    } catch (e) {
      state = MenusPageState.error;
    }
  }

  Future<void> fetchCategories() async {
    state = MenusPageState.busy;
    try {
      CategoriesService categoriesService = CategoriesService();
      QuerySnapshot snapshot = await categoriesService.getCategories().first;
      _categories = snapshot.docs
          .map((doc) => CategoriesModel.fromFirestore(doc))
          .toList();
      state = MenusPageState.idle;
    } catch (e) {
      state = MenusPageState.error;
    }
  }

  List<CategoriesModel> getFilteredCategories(String parentCategory) {
    return _categories
        .where((category) => category.parentCategory == parentCategory)
        .toList();
  }

  Future<void> addMenu(String parentCategory, String category, String product,
      String content, String price, String imgURL, String menuID) async {
    state = MenusPageState.busy;
    try {
      MenusService menusService = MenusService();
      MenusModel newMenu = MenusModel(
          Timestamp.now(),
          currentUser!.name! + currentUser!.lastName!,
          category,
          content,
          parentCategory,
          currentUser!.name! + " " + currentUser!.lastName!,
          Timestamp.now(),
          menuID,
          imgURL,
          price,
          product);
      await menusService.addMenu(newMenu);
      _menus.add(newMenu);
      state = MenusPageState.idle;
    } catch (e) {
      state = MenusPageState.error;
    }
  }
}
