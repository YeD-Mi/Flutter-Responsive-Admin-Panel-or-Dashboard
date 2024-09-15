import 'package:admin/models/MyFiles.dart';
import 'package:admin/responsive.dart';
import 'package:admin/screens/dashboard/dasboard_model_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../constants.dart';
import 'file_info_card.dart';

class MyFiles extends StatelessWidget {
  MyFiles({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pageViewModel = Provider.of<DashboardPageViewModel>(context);
    final Size _size = MediaQuery.of(context).size;

    List<CloudStorageInfo> demoMyFiles = [
      CloudStorageInfo(
        title: "Siparişler",
        numOfFiles: pageViewModel.ordersCount,
        svgSrc: "assets/icons/Documents.svg",
        totalStorage: "",
        color: primaryColor,
        percentage: 35,
      ),
      CloudStorageInfo(
        title: "Masalar",
        numOfFiles: pageViewModel.tablesCount,
        svgSrc: "assets/icons/google_drive.svg",
        totalStorage: "",
        color: Color(0xFFFFA113),
        percentage: 35,
      ),
      CloudStorageInfo(
        title: "Kategoriler",
        numOfFiles: pageViewModel.categoriesCount,
        svgSrc: "assets/icons/one_drive.svg",
        totalStorage: "",
        color: Color(0xFFA4CDFF),
        percentage: 10,
      ),
      CloudStorageInfo(
        title: "Menüler",
        numOfFiles: pageViewModel.menusCount,
        svgSrc: "assets/icons/drop_box.svg",
        totalStorage: "",
        color: Color(0xFF007EE5),
        percentage: 78,
      ),
    ];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Enjula Dashboard",
              style: Theme.of(context).textTheme.titleMedium,
            )
          ],
        ),
        SizedBox(height: defaultPadding),
        Responsive(
          mobile: FileInfoCardGridView(
            crossAxisCount: _size.width < 650 ? 2 : 4,
            childAspectRatio: _size.width < 650 && _size.width > 350 ? 1.3 : 1,
            demoMyFiles: demoMyFiles, // Burada parametre olarak geçiriyoruz
          ),
          tablet: FileInfoCardGridView(
            demoMyFiles: demoMyFiles, // Burada parametre olarak geçiriyoruz
          ),
          desktop: FileInfoCardGridView(
            childAspectRatio: _size.width < 1400 ? 1.1 : 1.4,
            demoMyFiles: demoMyFiles, // Burada parametre olarak geçiriyoruz
          ),
        ),
      ],
    );
  }
}

class FileInfoCardGridView extends StatelessWidget {
  const FileInfoCardGridView({
    Key? key,
    this.crossAxisCount = 4,
    this.childAspectRatio = 1,
    required this.demoMyFiles, // Parametre olarak ekliyoruz
  }) : super(key: key);

  final int crossAxisCount;
  final double childAspectRatio;
  final List<CloudStorageInfo> demoMyFiles; // Listeyi tanımlıyoruz

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: demoMyFiles.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: defaultPadding,
        mainAxisSpacing: defaultPadding,
        childAspectRatio: childAspectRatio,
      ),
      itemBuilder: (context, index) => FileInfoCard(info: demoMyFiles[index]),
    );
  }
}
