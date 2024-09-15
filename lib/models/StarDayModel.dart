import 'package:cloud_firestore/cloud_firestore.dart';

class StarModel {
  String? menu_id;

  StarModel(this.menu_id);

  StarModel.fromJson(Map<String, dynamic> json) {
    menu_id = json["menu_id"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data["menu_id"] = menu_id;

    return data;
  }

  factory StarModel.fromFirestore(DocumentSnapshot doc) {
    return StarModel.fromJson(doc.data() as Map<String, dynamic>);
  }
}
