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

  Future<void> addNewMenuAndRefresh(
      String parentCategory,
      String parentCategory_en,
      String category,
      String category_en,
      String product,
      String product_en,
      String content,
      String content_en,
      String price,
      String imageUrl,
      String menuID,
      List<Map<String, String>> priceOptions) async {
    await addMenu(
        parentCategory,
        parentCategory_en,
        category,
        category_en,
        product,
        product_en,
        content,
        content_en,
        price,
        imageUrl,
        menuID,
        priceOptions);
    await fetchMenus(); // Menüleri yeniden çek
    notifyListeners(); // UI'ı güncelle
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

  Future<void> updateMenu(
      String menuID,
      String parentCategory,
      String parentCategory_en,
      String category,
      String category_en,
      String product,
      String product_en,
      String content,
      String content_en,
      String price,
      String imgURL,
      List<Map<String, String>> priceOptions) async {
    state = MenusPageState.busy;
    try {
      MenusService menusService = MenusService();

      // priceOptions parametre olarak alınır ve MenusModel'e eklenir
      MenusModel updatedMenu = MenusModel(
        Timestamp.now(),
        currentUser!.name! + " " + currentUser!.lastName!,
        category,
        category_en,
        content,
        content_en,
        parentCategory,
        parentCategory_en,
        currentUser!.name! + " " + currentUser!.lastName!,
        Timestamp.now(),
        menuID,
        imgURL,
        price,
        product,
        product_en,
        priceOptions, // priceOptions burada modele ekleniyor
      );

      await menusService.updateMenu(updatedMenu);

      // Yerel listeyi güncelle
      int index = _menus.indexWhere((menu) => menu.menuID == menuID);
      if (index != -1) {
        _menus[index] = updatedMenu;
      }

      state = MenusPageState.idle;
      notifyListeners();
    } catch (e) {
      state = MenusPageState.error;
    }
  }

  Future<void> addMenu(
      String parentCategory,
      String parentCategory_en,
      String category,
      String category_en,
      String product,
      String product_en,
      String content,
      String content_en,
      String price,
      String imgURL,
      String menuID,
      List<Map<String, String>> priceOptions) async {
    state = MenusPageState.busy;
    try {
      MenusService menusService = MenusService();

      // priceOptions parametre olarak alınır ve MenusModel'e eklenir
      MenusModel newMenu = MenusModel(
        Timestamp.now(),
        currentUser!.name! + " " + currentUser!.lastName!,
        category,
        category_en,
        content,
        content_en,
        parentCategory,
        parentCategory_en,
        currentUser!.name! + " " + currentUser!.lastName!,
        Timestamp.now(),
        menuID,
        imgURL,
        price,
        product,
        product_en,
        priceOptions, // priceOptions burada modele ekleniyor
      );

      await menusService.addMenu(newMenu);
      _menus.add(newMenu);
      state = MenusPageState.idle;
    } catch (e) {
      state = MenusPageState.error;
    }
  }

  Future<void> deleteMenu(String menuID) async {
    state = MenusPageState.busy;
    try {
      MenusService menusService = MenusService();
      await menusService.deleteMenu(menuID);
      _menus.removeWhere((menu) => menu.menuID == menuID);
      state = MenusPageState.idle;
    } catch (e) {
      state = MenusPageState.error;
    }
  }
}
