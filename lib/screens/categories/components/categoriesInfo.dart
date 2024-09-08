import 'package:admin/date_service.dart';
import 'package:admin/models/CategoriesModel.dart';
import 'package:admin/screens/categories/categories_model_screen.dart';
import 'package:admin/screens/categories/components/add_category_dialog.dart';
import 'package:admin/screens/categories/components/edit_category_dialog.dart';
import 'package:flutter/material.dart';
import 'package:admin/responsive.dart';
import 'package:provider/provider.dart';
import '../../../constants.dart';

class Categoriesinfo extends StatefulWidget {
  const Categoriesinfo({Key? key}) : super(key: key);

  @override
  _CategoriesInfoState createState() => _CategoriesInfoState();
}

class _CategoriesInfoState extends State<Categoriesinfo> {
  late Future<void> _fetchCategoriesFuture;

  @override
  void initState() {
    super.initState();
    _fetchCategoriesFuture =
        Provider.of<CategoriesPageViewModel>(context, listen: false)
            .fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    final myCategories = Provider.of<CategoriesPageViewModel>(context);
    return FutureBuilder(
      future: _fetchCategoriesFuture,
      builder: (context, snapshot) {
        if (myCategories.state == CategoriesPageState.busy) {
          return Center(child: CircularProgressIndicator());
        } else if (myCategories.state == CategoriesPageState.error) {
          return Center(child: Text('Error loading Categories'));
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
                    ElevatedButton.icon(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: defaultPadding * 1.5,
                          vertical: defaultPadding /
                              (Responsive.isMobile(context) ? 2 : 1),
                        ),
                      ),
                      onPressed: () {
                        showAddCategoryDialog(context);
                      },
                      icon: Icon(Icons.add),
                      label: Text("Yeni Kategori"),
                    ),
                  ],
                ),
                SizedBox(
                  width: double.infinity,
                  child: DataTable(
                    columnSpacing: defaultPadding,
                    columns: [
                      DataColumn(
                        label: Text("Kategori Adı"),
                      ),
                      DataColumn(
                        label: Text("Oluşturan"),
                      ),
                      DataColumn(
                        label: Text("Son Değişiklik"),
                      ),
                      DataColumn(
                        label: Text(" "),
                      ),
                    ],
                    rows: List.generate(
                      myCategories.categories.length,
                      (index) => categoryInfoDataRow(
                          myCategories.categories[index], context),
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

DataRow categoryInfoDataRow(
    CategoriesModel categoryInfo, BuildContext context) {
  return DataRow(
    cells: [
      DataCell(Text(categoryInfo.name!)),
      DataCell(Text(categoryInfo.creative!)),
      DataCell(Text(DateService()
          .convertTimeStampYearHoursFormat(categoryInfo.lastModifiedDate!))),
      DataCell(ElevatedButton(
          onPressed: () {
            showDetailCategoryDialog(categoryInfo, context);
          },
          child: Text("İşlem")))
    ],
  );
}
