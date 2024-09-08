import 'package:admin/constants.dart';
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

  Future<void> addNewTableAndRefresh(
      String name, String tableID, String qrURL) async {
    await addTable(tableID, name, qrURL);
    await fetchTables();
    notifyListeners();
  }

  Future<void> updateTable(
      String tableID, String parentTable, String name) async {
    state = TablesPageState.busy;
    try {
      TablesService tablesService = TablesService();
      TablesModel updatedTable = TablesModel(
        Timestamp.now(),
        currentUser!.name! + " " + currentUser!.lastName!,
        tableID,
        tableID, //qr gelecek
        name,
        currentUser!.name! + " " + currentUser!.lastName!,
        Timestamp.now(),
      );
      await tablesService.updateTable(updatedTable);

      state = TablesPageState.idle;
      await fetchTables();
      notifyListeners();
    } catch (e) {
      state = TablesPageState.error;
    }
  }

  Future<void> addTable(String tableID, String name, String qrURL) async {
    state = TablesPageState.busy;
    try {
      TablesService tablesService = TablesService();
      TablesModel newTable = TablesModel(
        Timestamp.now(),
        currentUser!.name! + " " + currentUser!.lastName!,
        tableID,
        qrURL,
        name,
        currentUser!.name! + " " + currentUser!.lastName!,
        Timestamp.now(),
      );
      await tablesService.addTable(newTable);
      _tables.add(newTable);
      state = TablesPageState.idle;
    } catch (e) {
      state = TablesPageState.error;
    }
  }

  Future<void> deleteTable(String tableID) async {
    state = TablesPageState.busy;
    try {
      TablesService tablesService = TablesService();
      await tablesService.deleteTable(tableID);
      _tables.removeWhere((table) => table.tableID == tableID);
      state = TablesPageState.idle;
    } catch (e) {
      state = TablesPageState.error;
    }
  }
}
