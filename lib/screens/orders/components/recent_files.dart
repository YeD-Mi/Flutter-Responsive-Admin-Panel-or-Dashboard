import 'package:admin/models/RecentFile.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../constants.dart';

class RecentFiles extends StatelessWidget {
  const RecentFiles({
    Key? key,
  }) : super(key: key);

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
            child: DataTable(
              columnSpacing: defaultPadding,
              // minWidth: 600,
              columns: [
                DataColumn(
                  label: Text("Masa No"),
                ),
                DataColumn(
                  label: Text("Müşteri Ad Soyad"),
                ),
                DataColumn(
                  label: Text("Tarih"),
                ),
                DataColumn(
                  label: Text("Sipariş Durumu"),
                ),
                DataColumn(
                  label: Text("-"),
                ),
              ],
              rows: List.generate(
                demoRecentFiles.length,
                (index) => recentFileDataRow(demoRecentFiles[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

DataRow recentFileDataRow(OrderInfo fileInfo) {
  return DataRow(
    cells: [
      DataCell(
        Row(
          children: [
            SvgPicture.asset(
              fileInfo.icon!,
              height: 30,
              width: 30,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              child: Text(fileInfo.masa!),
            ),
          ],
        ),
      ),
      DataCell(Text(fileInfo.adsoyad!)),
      DataCell(Text(fileInfo.tarih!)),
      DataCell(Text(fileInfo.durum!)),
      DataCell(ElevatedButton(onPressed: () {}, child: Text("İşlem"))),
    ],
  );
}
