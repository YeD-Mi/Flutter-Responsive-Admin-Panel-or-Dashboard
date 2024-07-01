import 'package:admin/models/MenusModel.dart';
import 'package:admin/responsive.dart';
import 'package:admin/screens/Menus/Menus_model_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants.dart';

class Menusinfo extends StatefulWidget {
  const Menusinfo({Key? key}) : super(key: key);

  @override
  _MenusInfoState createState() => _MenusInfoState();
}

class _MenusInfoState extends State<Menusinfo> {
  late Future<void> _fetchMenusFuture;

  @override
  void initState() {
    super.initState();
    _fetchMenusFuture =
        Provider.of<MenusPageViewModel>(context, listen: false).fetchMenus();
  }

  @override
  Widget build(BuildContext context) {
    final myMenus = Provider.of<MenusPageViewModel>(context);

    return FutureBuilder(
      future: _fetchMenusFuture,
      builder: (context, snapshot) {
        if (myMenus.state == MenusPageState.busy) {
          return Center(child: CircularProgressIndicator());
        } else if (myMenus.state == MenusPageState.error) {
          return Center(child: Text('Error loading Menus'));
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
                      "Menüler",
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
                      label: Text("Yeni Menü"),
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
                        label: Text("Üst Kategori"),
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
                      myMenus.Menus.length,
                      (index) => menuInfoDataRow(myMenus.Menus[index]),
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
        title: Text('Yeni Menü'),
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
              final newMenu = MenusModel(
                  Timestamp.fromDate(DateTime.now()),
                  _creativeController.text,
                  _categoryIDController.text,
                  _nameController.text,
                  "",
                  "",
                  Timestamp.fromDate(DateTime.now()),
                  "",
                  [],
                  "",
                  "");
              Provider.of<MenusPageViewModel>(context, listen: false)
                  .addMenu(newMenu);
              Navigator.of(context).pop();
            },
            child: Text('Ekle'),
          ),
        ],
      );
    },
  );
}

DataRow menuInfoDataRow(MenusModel menuInfo) {
  return DataRow(
    cells: [
      DataCell(Text(menuInfo.parentCategory!)),
      DataCell(Text(menuInfo.category!)),
      DataCell(Text(menuInfo.creative!)),
      DataCell(Text(menuInfo.creationDate!.toDate().toString())),
    ],
  );
}
