import 'package:admin/constants.dart';
import 'package:admin/models/OrdersModel.dart';
import 'package:admin/responsive.dart';
import 'package:admin/screens/orders/orders_model_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

Future<void> showDetailOrderDialog(
    OrdersModel orderInfo, BuildContext context) async {
  final _orderIDController = TextEditingController();
  final _priceController = TextEditingController();
  final _orderStatusController = TextEditingController();

  _orderIDController.text = orderInfo.orderId!;
  _priceController.text = orderInfo.totalAmount!.toString();
  _orderStatusController.text = orderInfo.status!;

  double spaceHeight;
  if (Responsive.isDesktop(context)) {
    spaceHeight = 30.0;
  } else if (Responsive.isTablet(context)) {
    spaceHeight = 20.0;
  } else {
    spaceHeight = 10.0;
  }

  final myOrders = context.read<OrdersPageViewModel>();

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shadowColor: Colors.yellow,
            backgroundColor: Colors.grey.shade800,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            title: Center(
              child: Column(
                children: [
                  Text('Sipariş Düzenle (Masa ${orderInfo.tableNumber})',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  SizedBox(height: spaceHeight),
                  Divider(
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            content: SingleChildScrollView(
              child: Container(
                width: SizeConstants.width * 0.6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: spaceHeight),
                    DropdownButtonFormField<String>(
                      value: _orderStatusController.text.isNotEmpty
                          ? _orderStatusController.text
                          : null, // Default değeri ayarla
                      decoration: InputDecoration(
                        labelText: 'Sipariş Durumu',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      items: ['Sipariş Alındı', 'İptal Edildi', 'Tamamlandı']
                          .map((String status) {
                        return DropdownMenuItem<String>(
                          value: status,
                          child: Text(status),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _orderStatusController.text = newValue ??
                              ''; // Seçilen değeri _priceController'a yaz
                        });
                      },
                    ),

                    SizedBox(height: spaceHeight),
                    TextField(
                      controller: _orderIDController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Sipariş Numarası',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),

                    SizedBox(height: spaceHeight),
                    TextField(
                      controller: _priceController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Toplam Tutar (TL)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),

                    SizedBox(height: spaceHeight),
                    if (orderInfo.items != null &&
                        orderInfo.items!.isNotEmpty) ...[
                      Text(
                        'Sipariş Kalemleri:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: orderInfo.items!.length,
                        itemBuilder: (context, index) {
                          final item = orderInfo.items![index];
                          return Card(
                            color: Colors.grey.shade700,
                            margin: EdgeInsets.symmetric(vertical: 5.0),
                            child: ListTile(
                              title: Text(
                                item.menuItemTitle ?? 'Ürün Adı Yok',
                                style: TextStyle(color: Colors.white),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Fiyat: ${item.price ?? 0} TL',
                                      style:
                                          TextStyle(color: Colors.grey[300])),
                                  Text('Adet: ${item.quantity ?? 0}',
                                      style:
                                          TextStyle(color: Colors.grey[300])),
                                  Text('Tür: ${item.type ?? 'Bilinmiyor'}',
                                      style:
                                          TextStyle(color: Colors.grey[300])),
                                  if (item.note != null &&
                                      item.note!.isNotEmpty)
                                    Text('Not: ${item.note}',
                                        style:
                                            TextStyle(color: Colors.grey[300])),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                    SizedBox(height: 1.5 * spaceHeight),
                    Text(
                      "Oluşturma Tarihi: " +
                          DateFormat('dd-MM-yyyy HH:mm')
                              .format(orderInfo.creationDate!.toDate()),
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    SizedBox(height: 5),

                    // Son Değiştiren bilgisi dolu ise göster
                    if (orderInfo.lastModified != null &&
                        orderInfo.lastModified!.isNotEmpty) ...[
                      Text(
                        "Son Değiştiren: " + orderInfo.lastModified!,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      SizedBox(height: 5),
                    ],

                    // Son Değiştirme Tarihi dolu ise göster
                    if (orderInfo.lastModifiedDate != null) ...[
                      Text(
                        "Son Değiştirme Tarihi: " +
                            DateFormat('dd-MM-yyyy HH:mm')
                                .format(orderInfo.lastModifiedDate!.toDate()),
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      SizedBox(height: 5),
                    ],

                    Divider(
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('İptal', style: TextStyle(color: Colors.red)),
              ),
              ElevatedButton(
                onPressed: () {
                  Provider.of<OrdersPageViewModel>(context, listen: false)
                      .deleteOrder(orderInfo.orderId!)
                      .then((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Sipariş başarıyla silindi'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.of(context).pop();
                  }).catchError((error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Sipariş silinirken hata oluştu: $error'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // Button color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text('Sil'),
              ),
              ElevatedButton(
                onPressed: () {
                  myOrders
                      .updateOrder(
                    orderInfo.orderId!,
                    _orderStatusController.text,
                  )
                      .then((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Sipariş başarıyla güncellendi'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.of(context).pop();
                  }).catchError((error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text('Sipariş güncellenirken hata oluştu: $error'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // Button color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text('Kaydet'),
              )
            ],
          );
        },
      );
    },
  );
}
