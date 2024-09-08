import 'dart:async';
import 'package:admin/models/OrdersModel.dart';
import 'package:admin/screens/orders/orders_service.dart';
import 'package:flutter/material.dart';

enum OrdersPageState { idle, busy, error }

class OrdersPageViewModel with ChangeNotifier {
  OrdersPageState _state = OrdersPageState.idle;
  List<OrdersModel> _allOrders = []; // Tüm siparişler burada saklanır.
  List<OrdersModel> _filteredOrders =
      []; // Filtrelenmiş siparişler burada saklanır.
  OrdersPageState get state => _state;
  List<OrdersModel> get orders =>
      _filteredOrders; // Arayüze filtrelenmiş siparişleri gönder
  late StreamSubscription _ordersSubscription;
  String? _currentFilterStatus; // Şu anda kullanılan filtre durumu

  set state(OrdersPageState state) {
    _state = state;
    notifyListeners();
  }

  void listenToOrders() {
    state = OrdersPageState.busy;
    try {
      OrdersService ordersService = OrdersService();
      _ordersSubscription = ordersService.getOrders().listen((snapshot) {
        _allOrders =
            snapshot.docs.map((doc) => OrdersModel.fromFirestore(doc)).toList();

        // Veriler güncellendiğinde mevcut filtreyi uygula
        filterOrdersByStatus(_currentFilterStatus);
        state = OrdersPageState.idle;
      });
    } catch (e) {
      state = OrdersPageState.error;
    }
  }

  void filterOrdersByStatus(String? status) {
    _currentFilterStatus = status; // Şu anki filtre durumunu güncelle

    if (status == null || status == "Hepsi") {
      _filteredOrders = _allOrders; // Tüm siparişleri göster
    } else {
      _filteredOrders =
          _allOrders.where((order) => order.status == status).toList();
    }

    notifyListeners(); // Değişiklikleri bildir
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
      _allOrders.removeWhere((order) => order.orderId == orderId);
      filterOrdersByStatus(
          _currentFilterStatus); // Sipariş silindiğinde mevcut filtreyi uygula
      state = OrdersPageState.idle;
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
