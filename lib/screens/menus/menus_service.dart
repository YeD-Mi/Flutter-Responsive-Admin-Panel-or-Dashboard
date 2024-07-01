import 'package:admin/models/MenusModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MenusService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getMenus() {
    var ref = _firestore
        .collection("menus")
        .orderBy("creationDate", descending: true)
        .snapshots();
    return ref;
  }

  Future<void> addMenu(MenusModel newMenu) async {
    await _firestore.collection('Menus').add({});
  }
}
