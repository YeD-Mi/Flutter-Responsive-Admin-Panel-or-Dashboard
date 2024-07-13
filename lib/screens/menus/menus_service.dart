import 'package:admin/models/MenusModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MenusService {
  //final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _menusCollection =
      FirebaseFirestore.instance.collection('menus');

  Stream<QuerySnapshot> getMenus() {
    var ref =
        _menusCollection.orderBy("creationDate", descending: true).snapshots();
    return ref;
  }

  Future<void> addMenu(MenusModel newMenu) async {
    DocumentReference documentRef = _menusCollection.doc(newMenu.menuID);

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

  Future<void> deleteMenu(String menuID) {
    return _menusCollection.doc(menuID).delete();
  }

  Future<void> updateMenu(MenusModel updatedMenu) async {
    DocumentReference documentRef = _menusCollection.doc(updatedMenu.menuID);

    try {
      await documentRef.update({
        'category': updatedMenu.category,
        'parentCategory': updatedMenu.parentCategory,
        'lastModified': updatedMenu.lastModified,
        'lastModifiedDate': updatedMenu.lastModifiedDate,
        'title': updatedMenu.title,
        'contents': updatedMenu.contents,
        'price': updatedMenu.price,
        'image': updatedMenu.image,
      });
    } catch (e) {
      print("Menu güncelleme hatası: $e");
      throw Exception("Menu güncellenirken bir hata oluştu.");
    }
  }
}
