import 'package:cloud_firestore/cloud_firestore.dart';

class MenusModel {
  Timestamp? creationDate;
  String? creative;
  String? category;
  String? contents;
  String? parentCategory;
  String? lastModified;
  Timestamp? lastModifiedDate;
  String? menuID;
  List<String>? picURL;
  String? price;
  String? title;

  MenusModel(
      this.creationDate,
      this.creative,
      this.category,
      this.contents,
      this.parentCategory,
      this.lastModified,
      this.lastModifiedDate,
      this.menuID,
      this.picURL,
      this.price,
      this.title);

  MenusModel.fromJson(Map<String, dynamic> json) {
    creationDate = json["creationDate"] as Timestamp?;
    creative = json["creative"];
    category = json["category"];
    contents = json["contents"];
    parentCategory = json["parentCategory"];
    lastModified = json["lastModified"];
    lastModifiedDate = json["lastModifiedDate"];
    menuID = json["menuID"];
    picURL = (json["picURL"] as List<dynamic>?)
        ?.map((item) => item as String)
        .toList();
    price = json["price"];
    title = json["title"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data["creationDate"] = creationDate;
    data["creative"] = creative;
    data["category"] = category;
    data["contents"] = contents;
    data["parentCategory"] = parentCategory;
    data["lastModified"] = lastModified;
    data["lastModifiedDate"] = lastModifiedDate;
    data["menuID"] = menuID;
    data["picURL"] = picURL;
    data["price"] = price;
    data["title"] = title;
    return data;
  }

  factory MenusModel.fromFirestore(DocumentSnapshot doc) {
    return MenusModel.fromJson(doc.data() as Map<String, dynamic>);
  }
}
