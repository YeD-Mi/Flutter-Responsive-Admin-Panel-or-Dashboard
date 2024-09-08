import 'package:admin/constants.dart';
import 'package:admin/models/CategoriesModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CategoriesService {
  //final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _categoriesCollection =
      FirebaseFirestore.instance.collection('categories');

  Stream<QuerySnapshot> getCategories() {
    var ref = _categoriesCollection
        .orderBy("creationDate", descending: true)
        .snapshots();
    return ref;
  }

  Future<void> addCategory(CategoriesModel newCategory) async {
    DocumentReference documentRef =
        _categoriesCollection.doc(newCategory.categoryID);

    try {
      await documentRef.set({
        'creationDate': newCategory.creationDate,
        'creative': currentUser!.name! + " " + currentUser!.lastName!,
        'lastModified': currentUser!.name! + " " + currentUser!.lastName!,
        'lastModifiedDate': newCategory.lastModifiedDate,
        'categoryID': newCategory.categoryID,
        'name': newCategory.name,
        'name_en': newCategory.name_en,
        'parentCategory': newCategory.parentCategory
      });
    } catch (e) {
      print("Kategori ekleme hatası: $e");
      throw Exception("Kategori eklenirken bir hata oluştu.");
    }
  }

  Future<void> deleteCategory(String categoryID) {
    return _categoriesCollection.doc(categoryID).delete();
  }

  Future<void> updateCategory(CategoriesModel updatedCategory) async {
    DocumentReference documentRef =
        _categoriesCollection.doc(updatedCategory.categoryID);

    try {
      await documentRef.update({
        'lastModified': updatedCategory.lastModified,
        'lastModifiedDate': updatedCategory.lastModifiedDate,
        'categoryID': updatedCategory.categoryID,
        'name': updatedCategory.name,
        'name_en': updatedCategory.name_en,
        'parentCategory': updatedCategory.parentCategory
      });
    } catch (e) {
      print("Kategori güncelleme hatası: $e");
      throw Exception("Kategori güncellenirken bir hata oluştu.");
    }
  }
}
