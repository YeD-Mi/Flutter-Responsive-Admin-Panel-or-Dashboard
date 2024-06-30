import 'package:admin/models/CategoriesModel.dart';
import 'package:admin/responsive.dart';
import 'package:admin/screens/categories/categories_model_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
          return Center(child: Text('Error loading categories'));
        } else {
          return Container(
            padding: EdgeInsets.all(defaultPadding),
            decoration: BoxDecoration(
              color: secondaryColor,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Kategoriler",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    ElevatedButton.icon(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: defaultPadding * 1.5,
                          vertical: defaultPadding /
                              (Responsive.isMobile(context) ? 2 : 1),
                        ),
                      ),
                      onPressed: () {
                        _showAddCategoryDialog(context);
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
                    // minWidth: 600,
                    columns: [
                      DataColumn(
                        label: Text("ID"),
                      ),
                      DataColumn(
                        label: Text("Başlık"),
                      ),
                      DataColumn(
                        label: Text("Oluşturan"),
                      ),
                      DataColumn(
                        label: Text("Oluşturma Tarihi"),
                      ),
                    ],
                    rows: List.generate(
                      myCategories.categories.length,
                      (index) =>
                          categoryInfoDataRow(myCategories.categories[index]),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}

void _showAddCategoryDialog(BuildContext context) {
  final _categoryIDController = TextEditingController();
  final _nameController = TextEditingController();
  final _creativeController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Yeni Kategori'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _categoryIDController,
                decoration: InputDecoration(labelText: 'Başlık'),
              ),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'QR URL'),
              ),
              TextField(
                controller: _creativeController,
                decoration: InputDecoration(labelText: 'Oluşturan'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              final newCategory = CategoriesModel(
                  Timestamp.fromDate(DateTime.now()),
                  _creativeController.text,
                  _categoryIDController.text,
                  _nameController.text);
              Provider.of<CategoriesPageViewModel>(context, listen: false)
                  .addCategory(newCategory);
              Navigator.of(context).pop();
            },
            child: Text('Ekle'),
          ),
        ],
      );
    },
  );
}

DataRow categoryInfoDataRow(CategoriesModel categoryInfo) {
  return DataRow(
    cells: [
      DataCell(Text(categoryInfo.categoryID!)),
      DataCell(Text(categoryInfo.name!)),
      DataCell(Text(categoryInfo.creative!)),
      DataCell(Text(categoryInfo.creationDate!.toDate().toString())),
    ],
  );
}
