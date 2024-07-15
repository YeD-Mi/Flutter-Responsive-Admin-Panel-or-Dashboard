import 'package:cloud_firestore/cloud_firestore.dart';

class OrdersService {
  //final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _ordersCollection =
      FirebaseFirestore.instance.collection('orders');

  Stream<QuerySnapshot> getOrders() {
    var ref =
        _ordersCollection.orderBy("creationDate", descending: true).snapshots();
    return ref;
  }

  Future<void> deleteOrder(String orderID) {
    return _ordersCollection.doc(orderID).delete();
  }

  Future<void> updateOrder(String orderID, String status) async {
    DocumentReference documentRef = _ordersCollection.doc(orderID);

    try {
      await documentRef.update({
        'status': status,
      });
    } catch (e) {
      print("Sipariş güncelleme hatası: $e");
      throw Exception("Sipariş güncellenirken bir hata oluştu.");
    }
  }
}
