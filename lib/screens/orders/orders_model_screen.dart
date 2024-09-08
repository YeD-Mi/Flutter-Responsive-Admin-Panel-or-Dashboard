import 'dart:async';
import 'package:admin/models/OrdersModel.dart';
import 'package:admin/screens/orders/orders_service.dart';
import 'package:flutter/material.dart';

enum OrdersPageState { idle, busy, error }

class OrdersPageViewModel with ChangeNotifier {
  OrdersPageState _state = OrdersPageState.idle;
  List<OrdersModel> _orders = [];
  OrdersPageState get state => _state;
  List<OrdersModel> get orders => _orders;
  late StreamSubscription _ordersSubscription; // StreamSubscription eklendi

  set state(OrdersPageState state) {
    _state = state;
    notifyListeners();
  }

  void listenToOrders() {
    state = OrdersPageState.busy;
    try {
      OrdersService ordersService = OrdersService();
      _ordersSubscription = ordersService.getOrders().listen((snapshot) {
        _orders =
            snapshot.docs.map((doc) => OrdersModel.fromFirestore(doc)).toList();
        state = OrdersPageState.idle;
        notifyListeners(); // Değişiklikleri dinleyip, anında arayüze yansıtır
      });
    } catch (e) {
      state = OrdersPageState.error;
    }
  }

  Future<void> updateOrder(String orderId, String status) async {
    state = OrdersPageState.busy;
    try {
      OrdersService ordersService = OrdersService();
      await ordersService.updateOrder(orderId, status);
      state = OrdersPageState.idle;
      notifyListeners();
    } catch (e) {
      state = OrdersPageState.error;
    }
  }

  Future<void> deleteOrder(String orderId) async {
    state = OrdersPageState.busy;
    try {
      OrdersService ordersService = OrdersService();
      await ordersService.deleteOrder(orderId);
      _orders.removeWhere((order) => order.orderId == orderId);
      state = OrdersPageState.idle;
      notifyListeners();
    } catch (e) {
      state = OrdersPageState.error;
    }
  }

  @override
  void dispose() {
    _ordersSubscription.cancel(); // StreamSubscription'ı kapatmak için
    super.dispose();
  }
}
