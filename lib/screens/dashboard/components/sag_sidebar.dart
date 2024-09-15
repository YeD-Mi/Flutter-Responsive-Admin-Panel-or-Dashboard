import 'package:admin/screens/dashboard/dasboard_model_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants.dart';
import 'chart.dart';
import 'sag_sidebar_detay.dart';

class StorageDetails extends StatelessWidget {
  const StorageDetails({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // DashboardPageViewModel'den veri alıyoruz.
    final dashboardModel = Provider.of<DashboardPageViewModel>(context);

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
            "Trendler",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: defaultPadding),
          Chart(),
          StorageInfoCard(
            svgSrc: "assets/icons/Documents.svg",
            title: "Menü",
            amountOfFiles: dashboardModel.mostFrequentMenuItemId.toString(),
            numOfFiles: dashboardModel.mostFrequentMenuItemCount,
          ),
          StorageInfoCard(
            svgSrc: "assets/icons/folder.svg",
            title: "Masa",
            amountOfFiles: dashboardModel.mostFrequentTableNumber.toString(),
            numOfFiles: dashboardModel.mostFrequentTableCount,
          ),
          StorageInfoCard(
            svgSrc: "assets/icons/media.svg",
            title: "Siparişler",
            amountOfFiles:
                dashboardModel.last30DaysTotalAmount.toString() + " TL",
            numOfFiles: dashboardModel.last30DaysOrderCount,
          ),
        ],
      ),
    );
  }
}
