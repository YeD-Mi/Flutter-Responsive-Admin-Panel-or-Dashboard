import 'package:cloud_firestore/cloud_firestore.dart';

class TablesModel {
  Timestamp? creationDate;
  String? creative;
  String? tableID;
  String? qrURL;
  String? title;

  TablesModel(
      this.creationDate, this.creative, this.tableID, this.qrURL, this.title);

  TablesModel.fromJson(Map<String, dynamic> json) {
    creationDate = json["creationDate"] as Timestamp?;
    creative = json["creative"];
    tableID = json["tableID"];
    qrURL = json["qrURL"];
    title = json["title"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data["creationDate"] = creationDate;
    data["creative"] = creative;
    data["deskID"] = tableID;
    data["qrURL"] = qrURL;
    data["title"] = title;
    return data;
  }

  factory TablesModel.fromFirestore(DocumentSnapshot doc) {
    return TablesModel.fromJson(doc.data() as Map<String, dynamic>);
  }
}
