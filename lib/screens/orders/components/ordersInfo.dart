import 'package:admin/date_service.dart';
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
  String? _selectedParentCategory;
  final List<String> _parentCategories = [
    "Hepsi",
    "Sipariş Alındı",
    "Tamamlandı"
  ];

  @override
  void initState() {
    super.initState();
    _selectedParentCategory = _parentCategories[0];
    // Dinleme işlemini başlatıyoruz
    Provider.of<OrdersPageViewModel>(context, listen: false).listenToOrders();
  }

  @override
  Widget build(BuildContext context) {
    final myOrders = Provider.of<OrdersPageViewModel>(context);

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
                    vertical:
                        defaultPadding / (Responsive.isMobile(context) ? 2 : 1),
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
            ],
          ),
          SizedBox(
            width: double.infinity,
            child: myOrders.state == OrdersPageState.busy
                ? Center(child: CircularProgressIndicator())
                : myOrders.state == OrdersPageState.error
                    ? Center(child: Text('Siparişler yüklenirken hata oluştu.'))
                    : DataTable(
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
          ),
        ],
      ),
    );
  }
}

DataRow orderInfoDataRow(OrdersModel orderInfo, BuildContext context) {
  return DataRow(
    cells: [
      DataCell(Text(orderInfo.tableNumber ?? '')),
      DataCell(Text(orderInfo.orderId ?? '')),
      DataCell(Text(DateService()
          .convertTimeStampYearHoursFormat(orderInfo.creationDate!))),
      DataCell(Text(orderInfo.totalAmount.toString() + " TL")),
      DataCell(Text(orderInfo.status ?? '')),
      DataCell(ElevatedButton(
          onPressed: () {
            showDetailOrderDialog(orderInfo, context);
          },
          child: Text("İşlem")))
    ],
  );
}
