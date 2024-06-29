import 'package:admin/models/TablesModel.dart';
import 'package:admin/screens/tables/tables_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum TablesPageState { idle, busy, error }

class TablesPageViewModel with ChangeNotifier {
  TablesPageState _state = TablesPageState.idle;
  List<TablesModel> _tables = [];

  TablesPageState get state => _state;
  List<TablesModel> get tables => _tables;

  set state(TablesPageState state) {
    _state = state;
    notifyListeners();
  }

  Future<void> fetchTables() async {
    state = TablesPageState.busy;
    try {
      TablesService tablesService = TablesService();
      QuerySnapshot snapshot = await tablesService.getTables().first;
      _tables =
          snapshot.docs.map((doc) => TablesModel.fromFirestore(doc)).toList();
      state = TablesPageState.idle;
    } catch (e) {
      state = TablesPageState.error;
    }
  }

  int get length => _tables.length;

  TablesModel operator [](int index) => _tables[index];

  Future<void> addTable(TablesModel newTable) async {
    state = TablesPageState.busy;
    try {
      TablesService tablesService = TablesService();
      await tablesService.addTable(newTable);
      _tables.add(newTable);
      state = TablesPageState.idle;
    } catch (e) {
      state = TablesPageState.error;
    }
  }
}
