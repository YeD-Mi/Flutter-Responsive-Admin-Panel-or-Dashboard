import 'package:cloud_firestore/cloud_firestore.dart';

class CategoriesModel {
  Timestamp? creationDate;
  String? creative;
  String? categoryID;
  String? name;
  String? parentCategory;

  CategoriesModel(this.creationDate, this.creative, this.categoryID, this.name);

  CategoriesModel.fromJson(Map<String, dynamic> json) {
    creationDate = json["creationDate"] as Timestamp?;
    creative = json["creative"];
    categoryID = json["categoryID"];
    name = json["name"];
    parentCategory = json["parentCategory"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data["creationDate"] = creationDate;
    data["creative"] = creative;
    data["categoryID"] = categoryID;
    data["name"] = name;
    data["parentCategory"] = parentCategory;
    return data;
  }

  factory CategoriesModel.fromFirestore(DocumentSnapshot doc) {
    return CategoriesModel.fromJson(doc.data() as Map<String, dynamic>);
  }
}
