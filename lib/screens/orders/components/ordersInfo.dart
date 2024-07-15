import 'package:admin/responsive.dart';
import 'package:admin/screens/orders/components/edit_order_dialog.dart';
import 'package:flutter/material.dart';
import 'package:admin/models/OrdersModel.dart';
import 'package:admin/screens/orders/orders_model_screen.dart';
import 'package:provider/provider.dart';
import '../../../constants.dart';

class Ordersinfo extends StatefulWidget {
  const Ordersinfo({Key? key}) : super(key: key);

  @override
  _OrdersInfoState createState() => _OrdersInfoState();
}

class _OrdersInfoState extends State<Ordersinfo> {
  late Future<void> _fetchOrdersFuture;

  @override
  void initState() {
    super.initState();
    _fetchOrdersFuture =
        Provider.of<OrdersPageViewModel>(context, listen: false).fetchOrders();
    _selectedParentCategory = _parentCategories[0];
  }

  String? _selectedParentCategory;
  final List<String> _parentCategories = [
    "Hepsi",
    "Sipariş Alındı",
    "Tamamlandı"
  ];

  @override
  Widget build(BuildContext context) {
    final myOrders = Provider.of<OrdersPageViewModel>(context);
    return FutureBuilder(
      future: _fetchOrdersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error loading Orders'));
        } else {
          return Container(
            padding: EdgeInsets.all(defaultPadding),
            decoration: BoxDecoration(
              color: secondaryColor,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: SizeConstants.width * 0.3,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: defaultPadding * 1.5,
                          vertical: defaultPadding /
                              (Responsive.isMobile(context) ? 2 : 1),
                        ),
                        child: DropdownButtonFormField<String>(
                          value: _selectedParentCategory,
                          decoration: InputDecoration(
                            labelText: 'Durum',
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
                            setState(() {
                              _selectedParentCategory = newValue;
                            });
                          },
                        ),
                      ),
                    ),
                    /*    ElevatedButton.icon(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: defaultPadding * 1.5,
                          vertical: defaultPadding /
                              (Responsive.isMobile(context) ? 2 : 1),
                        ),
                      ),
                      onPressed: () {},
                      icon: Icon(Icons.add),
                      label: Text("Yeni Menü"),
                    ),*/
                  ],
                ),
                SizedBox(
                  width: double.infinity,
                  child: DataTable(
                    columnSpacing: defaultPadding,
                    columns: [
                      DataColumn(
                        label: Text("Masa Numarası"),
                      ),
                      DataColumn(
                        label: Text("Sipariş Numarası"),
                      ),
                      DataColumn(
                        label: Text("Sipariş Tarihi"),
                      ),
                      DataColumn(
                        label: Text("Toplam Fiyat"),
                      ),
                      DataColumn(
                        label: Text("Durum"),
                      ),
                      DataColumn(
                        label: Text(" "),
                      ),
                    ],
                    rows: List.generate(
                      myOrders.orders.length,
                      (index) =>
                          orderInfoDataRow(myOrders.orders[index], context),
                    ),
                  ),
                )
              ],
            ),
          );
        }
      },
    );
  }
}

DataRow orderInfoDataRow(OrdersModel orderInfo, BuildContext context) {
  return DataRow(
    cells: [
      DataCell(Text(orderInfo.tableNumber ?? '')),
      DataCell(Text(orderInfo.orderID ?? '')),
      DataCell(Text(orderInfo.totalAmount?.toString() ?? '')),
      DataCell(Text(orderInfo.totalAmount.toString())),
      DataCell(Text(orderInfo.status ?? '')),
      DataCell(ElevatedButton(
          onPressed: () {
            showDetailOrderDialog(orderInfo, context);
          },
          child: Text("İşlem")))
    ],
  );
}
