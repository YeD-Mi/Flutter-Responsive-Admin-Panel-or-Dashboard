import 'package:admin/models/TablesModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TablesService {
  //final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _tablesCollection =
      FirebaseFirestore.instance.collection('tables');

  Stream<QuerySnapshot> getTables() {
    var ref =
        _tablesCollection.orderBy("creationDate", descending: true).snapshots();
    return ref;
  }

  Future<void> addTable(TablesModel newTable) async {
    print("Birazdan veri yazacağım - addTableService");
    DocumentReference documentRef = _tablesCollection.doc(newTable.tableID);

    try {
      await documentRef.set({
        'creationDate': newTable.creationDate,
        'creative': newTable.creative,
        'lastModified': newTable.lastModified,
        'lastModifiedDate': newTable.lastModifiedDate,
        'tableID': newTable.tableID,
        'title': newTable.title,
        'qrURL': newTable.qrURL
      });
      print("Masa eklendi");
    } catch (e) {
      print("Masa ekleme hatası: $e");
      throw Exception("Masa eklenirken bir hata oluştu.");
    }
  }

  Future<void> deleteTable(String tableID) {
    return _tablesCollection.doc(tableID).delete();
  }

  Future<void> updateTable(TablesModel updatedTable) async {
    DocumentReference documentRef = _tablesCollection.doc(updatedTable.tableID);

    try {
      await documentRef.update({
        // 'creationDate': updatedTable.creationDate,
        // 'creative': updatedTable.creative,
        'lastModified': updatedTable.lastModified,
        'lastModifiedDate': updatedTable.lastModifiedDate,
        'tableID': updatedTable.tableID,
        'title': updatedTable.title,
      });
    } catch (e) {
      print("Masa güncelleme hatası: $e");
      throw Exception("Masa güncellenirken bir hata oluştu.");
    }
  }
}
