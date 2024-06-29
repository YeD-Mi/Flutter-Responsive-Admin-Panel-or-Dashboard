import 'package:admin/models/TablesModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TablesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getTables() {
    var ref = _firestore
        .collection("tables")
        .orderBy("creationDate", descending: true)
        .snapshots();
    return ref;
  }

  Future<void> addTable(TablesModel newTable) async {
    await _firestore.collection('tables').add({
      'tableID': newTable.tableID,
      'qrURL': newTable.qrURL,
      'creative': newTable.creative,
      'creationDate': newTable.creationDate,
    });
  }
}
