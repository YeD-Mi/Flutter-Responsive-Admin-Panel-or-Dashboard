import 'package:admin/constants.dart';
import 'package:admin/models/OrdersModel.dart';
import 'package:admin/responsive.dart';
import 'package:admin/screens/orders/orders_model_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

Future<void> showDetailOrderDialog(
    OrdersModel orderInfo, BuildContext context) async {
  final _productController = TextEditingController();
  final _contentController = TextEditingController();
  final _priceController = TextEditingController();

  _productController.text = orderInfo.status!;
  _contentController.text = orderInfo.status!;
  _priceController.text = orderInfo.status!;

  double spaceHeight;
  if (Responsive.isDesktop(context)) {
    spaceHeight = 30.0;
  } else if (Responsive.isTablet(context)) {
    spaceHeight = 20.0;
  } else {
    spaceHeight = 10.0;
  }
  String? _selectedParentCategory = orderInfo.status!;
  List<String> _parentCategories = ["Sipariş Alındı", "İçecek"];
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
                  Text('Sipariş Düzenle',
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
                width: SizeConstants.width * 0.3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: spaceHeight),
                    DropdownButtonFormField<String>(
                      value: _selectedParentCategory,
                      decoration: InputDecoration(
                        labelText: 'Üst Kategori',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      items: _parentCategories.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {});
                      },
                    ),

                    SizedBox(height: spaceHeight),
                    TextField(
                      controller: _productController,
                      decoration: InputDecoration(
                        labelText: 'Ürün',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                    SizedBox(height: spaceHeight),
                    TextField(
                      controller: _contentController,
                      maxLines: 3, // İçerik alanının üç satıra sığması için
                      decoration: InputDecoration(
                        labelText: 'İçerik',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                    SizedBox(height: spaceHeight),
                    TextField(
                      controller: _priceController,
                      decoration: InputDecoration(
                        labelText: 'Fiyat',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: spaceHeight),
                    // Image display and picker
                    SizedBox(height: 1.5 * spaceHeight),
                    Text(
                      "Oluşturan: " + orderInfo.status!,
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "Oluşturma Tarihi: " +
                          DateFormat('dd-MM-yyyy HH:mm')
                              .format(orderInfo.creationDate!.toDate()),
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "Son Değiştiren: " + orderInfo.lastModified!,
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "Son Değiştirme Tarihi: " +
                          DateFormat('dd-MM-yyyy HH:mm')
                              .format(orderInfo.lastModifiedDate!.toDate()),
                      style: TextStyle(color: Colors.grey[600]),
                    ),
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
                      .deleteOrder(orderInfo.orderID!)
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
                    orderInfo.orderID!,
                    _productController.text,
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
