import 'package:admin/models/OrdersModel.dart';
import 'package:admin/screens/orders/orders_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum OrdersPageState { idle, busy, error }

class OrdersPageViewModel with ChangeNotifier {
  OrdersPageState _state = OrdersPageState.idle;
  List<OrdersModel> _orders = [];
  OrdersPageState get state => _state;
  List<OrdersModel> get orders => _orders;

  set state(OrdersPageState state) {
    _state = state;
    notifyListeners();
  }

  Future<void> fetchOrders() async {
    state = OrdersPageState.busy;
    try {
      OrdersService ordersService = OrdersService();
      QuerySnapshot snapshot = await ordersService.getOrders().first;
      _orders =
          snapshot.docs.map((doc) => OrdersModel.fromFirestore(doc)).toList();
      state = OrdersPageState.idle;
    } catch (e) {
      state = OrdersPageState.error;
    }
  }

  Future<void> updateOrder(String orderID, String status) async {
    state = OrdersPageState.busy;
    try {
      OrdersService ordersService = OrdersService();
      await ordersService.updateOrder(orderID, status);
      state = OrdersPageState.idle;
      fetchOrders();
      notifyListeners();
    } catch (e) {
      state = OrdersPageState.error;
    }
  }

  Future<void> deleteOrder(String orderID) async {
    state = OrdersPageState.busy;
    try {
      OrdersService ordersService = OrdersService();
      await ordersService.deleteOrder(orderID);
      _orders.removeWhere((order) => order.orderID == orderID);
      state = OrdersPageState.idle;
    } catch (e) {
      state = OrdersPageState.error;
    }
  }
}
