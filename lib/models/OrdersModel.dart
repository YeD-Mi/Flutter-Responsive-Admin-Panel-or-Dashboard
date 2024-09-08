import 'package:cloud_firestore/cloud_firestore.dart';

class OrdersModel {
  Timestamp? creationDate;
  String? lastModified;
  Timestamp? lastModifiedDate;
  String? orderId;
  int? totalAmount;
  String? tableNumber;
  String? status;
  List<OrderItem>? items;

  OrdersModel(
      this.creationDate,
      this.lastModified,
      this.lastModifiedDate,
      this.orderId,
      this.totalAmount,
      this.tableNumber,
      this.status,
      this.items);

  OrdersModel.fromJson(Map<String, dynamic> json) {
    creationDate = json["creationDate"] as Timestamp?;
    lastModified = json["lastModified"];
    lastModifiedDate = json["lastModifiedDate"];
    orderId = json["orderId"];
    totalAmount = json["totalAmount"];
    tableNumber = json["tableNumber"];
    status = json["status"];
    if (json["items"] != null) {
      items = [];
      json["items"].forEach((v) {
        items!.add(OrderItem.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["creationDate"] = creationDate;
    data["lastModified"] = lastModified;
    data["lastModifiedDate"] = lastModifiedDate;
    data["orderId"] = orderId;
    data["totalAmount"] = totalAmount;
    data["tableNumber"] = tableNumber;
    data["status"] = status;
    if (items != null) {
      data["items"] = items!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  factory OrdersModel.fromFirestore(DocumentSnapshot doc) {
    return OrdersModel.fromJson(doc.data() as Map<String, dynamic>);
  }
}

class OrderItem {
  String? menuItemId;
  String? menuItemTitle;
  String? note;
  int? price;
  int? quantity;
  String? type;

  OrderItem(this.menuItemId, this.menuItemTitle, this.note, this.price,
      this.quantity, this.type);

  OrderItem.fromJson(Map<String, dynamic> json) {
    menuItemId = json["menuItemId"];
    menuItemTitle = json["menuItemTitle"];
    note = json["note"];
    price = json["price"];
    quantity = json["quantity"];
    type = json["type"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["menuItemId"] = menuItemId;
    data["menuItemTitle"] = menuItemTitle;
    data["note"] = note;
    data["price"] = price;
    data["quantity"] = quantity;
    data["type"] = type;

    return data;
  }
}
