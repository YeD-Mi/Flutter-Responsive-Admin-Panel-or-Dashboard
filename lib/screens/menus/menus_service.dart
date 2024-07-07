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
    var ref = _firestore.collection("menus");
    DocumentReference documentRef = ref.doc(newMenu.menuID);

    try {
      await documentRef.set({
        'creationDate': newMenu.creationDate,
        'creative': newMenu.creative,
        'category': newMenu.category,
        'parentCategory': newMenu.parentCategory,
        'lastModified': newMenu.lastModified,
        'lastModifiedDate': newMenu.lastModifiedDate,
        'menuID': newMenu.menuID,
        'title': newMenu.title,
        'contents': newMenu.contents,
        'price': newMenu.price,
        'image': newMenu.image,
      });
    } catch (e) {
      print("Menu ekleme hatası: $e");
      throw Exception("Menu eklenirken bir hata oluştu.");
    }
  }
}
