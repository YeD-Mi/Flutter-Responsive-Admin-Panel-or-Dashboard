import 'package:cloud_firestore/cloud_firestore.dart';

class UsersModel {
  Timestamp? creationDate;
  String? creative;
  bool? isActive;
  String? lastName;
  String? name;
  String? email;
  String? password;
  String? picURL;
  String? userID;

  UsersModel(this.creationDate, this.creative, this.isActive, this.lastName,
      this.name, this.email, this.password, this.picURL, this.userID);

  UsersModel.fromJson(Map<String, dynamic> json) {
    creationDate = json["creationDate"] as Timestamp?;
    creative = json["creative"];
    isActive = json["isActive"];
    lastName = json["lastName"];
    name = json["name"];
    email = json["email"];
    password = json["password"];
    picURL = json["picURL"];
    userID = json["userID"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data["creationDate"] = creationDate;
    data["creative"] = creative;
    data["isActive"] = isActive;
    data["lastName"] = lastName;
    data["name"] = name;
    data["email"] = email;
    data["password"] = password;
    data["picURL"] = picURL;
    data["userID"] = userID;

    return data;
  }

  factory UsersModel.fromFirestore(DocumentSnapshot doc) {
    return UsersModel.fromJson(doc.data() as Map<String, dynamic>);
  }
}
