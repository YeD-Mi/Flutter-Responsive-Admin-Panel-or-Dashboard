import 'package:cloud_firestore/cloud_firestore.dart';

class MenusModel {
  Timestamp? creationDate;
  String? creative;
  String? category;
  String? category_en;
  String? contents;
  String? contents_en;
  String? parentCategory;
  String? parentCategory_en;
  String? lastModified;
  Timestamp? lastModifiedDate;
  String? menuID;
  String? image;
  String? price;
  String? title;
  String? title_en;
  List<Map<String, String>>? priceOptions;

  MenusModel(
      this.creationDate,
      this.creative,
      this.category,
      this.category_en,
      this.contents,
      this.contents_en,
      this.parentCategory,
      this.parentCategory_en,
      this.lastModified,
      this.lastModifiedDate,
      this.menuID,
      this.image,
      this.price,
      this.title,
      this.title_en,
      this.priceOptions);

  MenusModel.fromJson(Map<String, dynamic> json) {
    creationDate = json["creationDate"] as Timestamp?;
    creative = json["creative"];
    category = json["category"];
    category_en = json["category_en"];
    contents = json["contents"];
    contents_en = json["contents_en"];
    parentCategory = json["parentCategory"];
    parentCategory_en = json["parentCategory_en"];
    lastModified = json["lastModified"];
    lastModifiedDate = json["lastModifiedDate"];
    menuID = json["menuID"];
    image = json["image"];
    price = json["price"];
    title = json["title"];
    title_en = json["title_en"];

    // priceOptions verisini ekle
    if (json["priceOptions"] != null) {
      priceOptions = List<Map<String, String>>.from(
          json["priceOptions"].map((item) => Map<String, String>.from(item)));
    } else {
      priceOptions = [];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data["creationDate"] = creationDate;
    data["creative"] = creative;
    data["category"] = category;
    data["category_en"] = category_en;
    data["contents"] = contents;
    data["parentCategory"] = parentCategory;
    data["lastModified"] = lastModified;
    data["lastModifiedDate"] = lastModifiedDate;
    data["menuID"] = menuID;
    data["image"] = image;
    data["price"] = price;
    data["title"] = title;
    data["title_en"] = title_en;

    // priceOptions verisini ekle
    if (priceOptions != null) {
      data["priceOptions"] = priceOptions!
          .map((item) => {
                "type": item["type"]!,
                "type_en": item["type_en"]!,
                "price": item["price"]!
              })
          .toList();
    }
    return data;
  }

  factory MenusModel.fromFirestore(DocumentSnapshot doc) {
    return MenusModel.fromJson(doc.data() as Map<String, dynamic>);
  }
}
