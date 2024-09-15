import 'package:admin/date_service.dart';
import 'package:admin/screens/dashboard/dasboard_model_screen.dart';
import 'package:flutter/material.dart';
import '../../../constants.dart';

class RecentFiles extends StatelessWidget {
  const RecentFiles({
    Key? key,
    required this.viewModel,
  }) : super(key: key);

  final DashboardPageViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Son Siparişler",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(
            width: double.infinity,
            child: FutureBuilder(
              future: viewModel.fetchLastOrders(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Bir hata oluştu.'));
                }

                if (viewModel.lastOrders.isEmpty) {
                  return Center(child: Text('Sipariş bulunamadı.'));
                }

                // Renkler için bir liste
                final List<Color> colors = [
                  Colors.blueAccent,
                  Colors.greenAccent,
                  Colors.orangeAccent,
                  Colors.redAccent,
                  Colors.purpleAccent,
                  Colors.tealAccent,
                  Colors.amberAccent,
                ];

                return DataTable(
                  columnSpacing: 0,
                  columns: [
                    DataColumn(
                      label: Text("Masa No"),
                    ),
                    DataColumn(
                      label: Text("Tarih"),
                    ),
                    DataColumn(
                      label: Text("Durum"),
                    ),
                  ],
                  rows: List.generate(
                    viewModel.lastOrders.length,
                    (index) {
                      // Her satır için farklı renk atama
                      final color = colors[index % colors.length];

                      return DataRow(
                        cells: [
                          DataCell(Row(
                            children: [
                              Container(
                                width: 10, // Kutu genişliği
                                height: 10, // Kutu yüksekliği
                                color: color, // Kutu rengi
                              ),
                              SizedBox(width: 10),
                              Text(viewModel.lastOrders[index]['tableNumber'] ??
                                  ''),
                            ],
                          )),
                          DataCell(Text(DateService()
                              .convertTimeStampYearHoursFormat(viewModel
                                  .lastOrders[index]['creationDate']))),
                          DataCell(Text(
                              viewModel.lastOrders[index]['status'] ?? '')),
                        ],
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
