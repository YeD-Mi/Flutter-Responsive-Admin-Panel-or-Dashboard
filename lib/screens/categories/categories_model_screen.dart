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

  int get length => _categories.length;

  CategoriesModel operator [](int index) => _categories[index];

  Future<void> addCategory(CategoriesModel newCategory) async {
    state = CategoriesPageState.busy;
    try {
      CategoriesService categoriesService = CategoriesService();
      await categoriesService.addCategori(newCategory);
      _categories.add(newCategory);
      state = CategoriesPageState.idle;
    } catch (e) {
      state = CategoriesPageState.error;
    }
  }
}
