import 'package:admin/models/CategoriesModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CategoriesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getCategories() {
    var ref = _firestore
        .collection("categories")
        .orderBy("creationDate", descending: true)
        .snapshots();
    return ref;
  }

  Future<void> addCategori(CategoriesModel newCategory) async {
    await _firestore.collection('categories').add({
      'categoryID': newCategory.categoryID,
      'name': newCategory.name,
      'creative': newCategory.creative,
      'creationDate': newCategory.creationDate,
    });
  }
}
