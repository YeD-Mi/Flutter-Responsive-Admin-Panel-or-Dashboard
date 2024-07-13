import 'package:admin/screens/menus/components/add_menu_dialog.dart';
import 'package:admin/screens/menus/components/edit_menu_dialog.dart';
import 'package:flutter/material.dart';
import 'package:admin/models/MenusModel.dart';
import 'package:admin/responsive.dart';
import 'package:admin/screens/menus/menus_model_screen.dart';
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
                        showAddMenuDialog(context);
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
                    columns: [
                      DataColumn(
                        label: Text("Üst Kategori"),
                      ),
                      DataColumn(
                        label: Text("Kategori"),
                      ),
                      DataColumn(
                        label: Text("Ürün"),
                      ),
                      DataColumn(
                        label: Text("Fiyat"),
                      ),
                      DataColumn(
                        label: Text("Görsel"),
                      ),
                      DataColumn(
                        label: Text(" "),
                      ),
                    ],
                    rows: List.generate(
                      myMenus.menus.length,
                      (index) => menuInfoDataRow(myMenus.menus[index], context),
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

DataRow menuInfoDataRow(MenusModel menuInfo, BuildContext context) {
  return DataRow(
    cells: [
      DataCell(Text(menuInfo.parentCategory!)),
      DataCell(Text(menuInfo.category!)),
      DataCell(Text(menuInfo.title!)),
      DataCell(Text(menuInfo.price!)),
      DataCell(InkWell(
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Container(
                    width: SizeConstants.width * 0.5,
                    height: SizeConstants.height * 0.5,
                    child: Column(
                      children: [
                        Expanded(
                          child: Image.network(
                            menuInfo.image!,
                            fit: BoxFit.contain,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Kapat'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          child: Icon(Icons.image))),
      DataCell(ElevatedButton(
          onPressed: () {
            showDetailMenuDialog(menuInfo, context);
          },
          child: Text("İşlem")))
    ],
  );
}
