import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum DashboardPageState { idle, busy, error }

class DashboardPageViewModel with ChangeNotifier {
  set state(DashboardPageState state) {
    notifyListeners();
  }

  List<Map<String, dynamic>> _lastOrders = [];
  List<Map<String, dynamic>> get lastOrders => _lastOrders;

  int categoriesCount = 0;
  int menusCount = 0;
  int ordersCount = 0;
  int tablesCount = 0;

  String? mostFrequentTableNumber; // En çok tekrar eden tableNumber
  int mostFrequentTableCount = 0; // Bu tableNumber'ın kaç kez tekrarlandığı

  String? mostFrequentMenuItemId; // En çok tekrar eden MenuItemId
  int mostFrequentMenuItemCount = 0; // Bu MenuItemId'nin kaç kez tekrarlandığı

  int last30DaysOrderCount = 0; // Son 30 gün içerisindeki sipariş sayısı
  double last30DaysTotalAmount =
      0.0; // Son 30 gün içerisindeki siparişlerin toplam tutarı

  // Firestore cache özelliğini etkinleştir
  DashboardPageViewModel() {
    FirebaseFirestore.instance.settings =
        const Settings(persistenceEnabled: true);
  }

  Future<void> fetchLastOrders() async {
    state = DashboardPageState.busy;
    try {
      // Siparişleri getir (cache destekli)
      QuerySnapshot ordersSnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .orderBy('creationDate', descending: true)
          .limit(7)
          .get(GetOptions(source: Source.cache)); // Cache'den getir

      if (ordersSnapshot.docs.isEmpty) {
        // Eğer cache'de yoksa, Firestore'dan getir
        ordersSnapshot = await FirebaseFirestore.instance
            .collection('orders')
            .orderBy('creationDate', descending: true)
            .limit(7)
            .get();
      }

      _lastOrders = ordersSnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      // Aggregation query ile tüm koleksiyon sayıları tek seferde al
      await _fetchCounts();

      // Son 30 gün içerisindeki sipariş sayısını ve toplam tutarını hesapla
      await _calculateLast30DaysData();

      // Tüm veriler yüklendiğinde durum idle'a geçilir
      state = DashboardPageState.idle;
    } catch (e) {
      state = DashboardPageState.error;
    }
  }

  Future<void> _fetchCounts() async {
    try {
      // Firestore aggregation query ile tek istekte tüm sayıları getir
      AggregateQuerySnapshot categoriesAgg = await FirebaseFirestore.instance
          .collection('categories')
          .count()
          .get();
      AggregateQuerySnapshot menusAgg =
          await FirebaseFirestore.instance.collection('menus').count().get();
      AggregateQuerySnapshot ordersAgg =
          await FirebaseFirestore.instance.collection('orders').count().get();
      AggregateQuerySnapshot tablesAgg =
          await FirebaseFirestore.instance.collection('tables').count().get();

      categoriesCount = categoriesAgg.count ?? 0;
      menusCount = menusAgg.count ?? 0;
      ordersCount = ordersAgg.count ?? 0;
      tablesCount = tablesAgg.count ?? 0;
    } catch (e) {
      print("Error fetching document counts: $e");
    }
  }

  void _calculateMostFrequentTableNumber(
      List<QueryDocumentSnapshot> recentOrders) {
    // Table number frekanslarını tutacak bir map oluştur
    Map<String, int> tableNumberCounts = {};

    for (var orderDoc in recentOrders) {
      var order = orderDoc.data() as Map<String, dynamic>;
      String? tableNumber = order['tableNumber'] as String?;

      if (tableNumber != null) {
        // Eğer tableNumber daha önce eklenmişse sayısını arttır, eklenmemişse 1 olarak başlat
        tableNumberCounts[tableNumber] =
            (tableNumberCounts[tableNumber] ?? 0) + 1;
      }
    }

    // En sık geçen tableNumber'ı ve tekrar sayısını bul
    tableNumberCounts.forEach((tableNumber, count) {
      if (count > mostFrequentTableCount) {
        mostFrequentTableNumber = tableNumber;
        mostFrequentTableCount = count;
      }
    });
  }

  void _calculateMostFrequentMenuItemId(
      List<QueryDocumentSnapshot> recentOrders) {
    // MenuItemId frekanslarını tutacak bir map oluştur
    Map<String, int> menuItemIdCounts = {};

    for (var orderDoc in recentOrders) {
      var order = orderDoc.data() as Map<String, dynamic>;
      List<dynamic>? items = order['items'] as List<dynamic>?;

      if (items != null) {
        for (var item in items) {
          String? menuItemId = item['menuItemTitle'] as String?;

          if (menuItemId != null) {
            // Eğer menuItemId daha önce eklenmişse sayısını arttır, eklenmemişse 1 olarak başlat
            menuItemIdCounts[menuItemId] =
                (menuItemIdCounts[menuItemId] ?? 0) + 1;
          }
        }
      }
    }

    // En sık geçen MenuItemId'yi ve tekrar sayısını bul
    menuItemIdCounts.forEach((menuItemId, count) {
      if (count > mostFrequentMenuItemCount) {
        mostFrequentMenuItemId = menuItemId;
        mostFrequentMenuItemCount = count;
      }
    });
  }

  Future<void> _calculateLast30DaysData() async {
    try {
      DateTime now = DateTime.now();
      DateTime thirtyDaysAgo = now.subtract(Duration(days: 30));

      QuerySnapshot ordersSnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('creationDate', isGreaterThanOrEqualTo: thirtyDaysAgo)
          .get(GetOptions(source: Source.cache)); // Cache'den veri al

      if (ordersSnapshot.docs.isEmpty) {
        // Cache'de yoksa sunucudan getir
        ordersSnapshot = await FirebaseFirestore.instance
            .collection('orders')
            .where('creationDate', isGreaterThanOrEqualTo: thirtyDaysAgo)
            .get();
      }

      List<QueryDocumentSnapshot> recentOrders = ordersSnapshot.docs;

      last30DaysOrderCount = recentOrders.length;
      last30DaysTotalAmount = recentOrders.fold(
        0.0,
        (sum, doc) {
          double? totalAmount =
              (doc.data() as Map<String, dynamic>)['totalAmount'] as double?;
          return sum + (totalAmount ?? 0.0);
        },
      );

      // Son 30 gün içerisindeki verilerle en sık geçen tableNumber ve menuItemId'yi hesapla
      _calculateMostFrequentTableNumber(recentOrders);
      _calculateMostFrequentMenuItemId(recentOrders);
    } catch (e) {
      print("Error calculating last 30 days data: $e");
      last30DaysOrderCount = 0;
      last30DaysTotalAmount = 0.0;
    }
  }
}
