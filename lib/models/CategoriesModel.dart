import 'package:cloud_firestore/cloud_firestore.dart';

class CategoriesModel {
  Timestamp? creationDate;
  String? creative;
  String? categoryID;
  String? name;
  String? name_en;
  String? parentCategory;
  String? lastModified;
  Timestamp? lastModifiedDate;

  CategoriesModel(
      this.creationDate,
      this.creative,
      this.categoryID,
      this.name,
      this.name_en,
      this.lastModified,
      this.lastModifiedDate,
      this.parentCategory);

  CategoriesModel.fromJson(Map<String, dynamic> json) {
    creationDate = json["creationDate"] as Timestamp?;
    creative = json["creative"];
    categoryID = json["categoryID"];
    name = json["name"];
    name_en = json["name_en"];
    parentCategory = json["parentCategory"];
    lastModified = json["lastModified"];
    lastModifiedDate = json["lastModifiedDate"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data["creationDate"] = creationDate;
    data["creative"] = creative;
    data["categoryID"] = categoryID;
    data["name"] = name;
    data["name_en"] = name_en;
    data["parentCategory"] = parentCategory;
    data["lastModified"] = lastModified;
    data["lastModifiedDate"] = lastModifiedDate;
    return data;
  }

  factory CategoriesModel.fromFirestore(DocumentSnapshot doc) {
    return CategoriesModel.fromJson(doc.data() as Map<String, dynamic>);
  }
}
