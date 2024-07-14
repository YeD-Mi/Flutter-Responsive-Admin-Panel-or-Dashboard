import 'package:admin/constants.dart';
import 'package:admin/models/CategoriesModel.dart';
import 'package:admin/screens/categories/categories_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum CategoriesPageState { idle, busy, error }

class CategoriesPageViewModel with ChangeNotifier {
  CategoriesPageState _state = CategoriesPageState.idle;
  List<CategoriesModel> _categories = [];

  CategoriesPageState get state => _state;
  List<CategoriesModel> get categories => _categories;

  set state(CategoriesPageState state) {
    _state = state;
    notifyListeners();
  }

  Future<void> fetchCategories() async {
    state = CategoriesPageState.busy;
    try {
      CategoriesService categoriesService = CategoriesService();
      QuerySnapshot snapshot = await categoriesService.getCategories().first;
      _categories = snapshot.docs
          .map((doc) => CategoriesModel.fromFirestore(doc))
          .toList();
      state = CategoriesPageState.idle;
    } catch (e) {
      state = CategoriesPageState.error;
    }
  }

  Future<void> addNewCategoryAndRefresh(
      String parentCategory, String name, String categoryID) async {
    await addCategory(parentCategory, categoryID, name);
    await fetchCategories();
    notifyListeners();
  }

  List<CategoriesModel> getFilteredCategories(String parentCategory) {
    return _categories
        .where((category) => category.parentCategory == parentCategory)
        .toList();
  }

  Future<void> updateCategory(
      String categoryID, String parentCategory, String name) async {
    state = CategoriesPageState.busy;
    try {
      CategoriesService categoriesService = CategoriesService();
      CategoriesModel updatedCategory = CategoriesModel(
          Timestamp.now(),
          currentUser!.name! + " " + currentUser!.lastName!,
          categoryID,
          name,
          currentUser!.name! + " " + currentUser!.lastName!,
          Timestamp.now(),
          parentCategory);
      await categoriesService.updateCategory(updatedCategory);

      state = CategoriesPageState.idle;
      await fetchCategories();
      notifyListeners();
    } catch (e) {
      state = CategoriesPageState.error;
    }
  }

  Future<void> addCategory(
      String parentCategory, String categoryID, String name) async {
    state = CategoriesPageState.busy;
    try {
      CategoriesService categoriesService = CategoriesService();
      CategoriesModel newCategory = CategoriesModel(
          Timestamp.now(),
          currentUser!.name! + currentUser!.lastName!,
          categoryID,
          name,
          currentUser!.name! + " " + currentUser!.lastName!,
          Timestamp.now(),
          parentCategory);
      await categoriesService.addCategory(newCategory);
      _categories.add(newCategory);
      state = CategoriesPageState.idle;
    } catch (e) {
      state = CategoriesPageState.error;
    }
  }

  Future<void> deleteCategory(String categoryID) async {
    state = CategoriesPageState.busy;
    try {
      CategoriesService categoriesService = CategoriesService();
      await categoriesService.deleteCategory(categoryID);
      _categories.removeWhere((category) => category.categoryID == categoryID);
      state = CategoriesPageState.idle;
    } catch (e) {
      state = CategoriesPageState.error;
    }
  }
}
