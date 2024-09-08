import 'package:admin/constants.dart';
import 'package:admin/models/TablesModel.dart';
import 'package:admin/responsive.dart';
import 'package:admin/screens/tables/tables_model_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

Future<void> showDetailTableDialog(
    TablesModel tableInfo, BuildContext context) async {
  final _titleController = TextEditingController();
  _titleController.text = tableInfo.title!;

  double spaceHeight;
  if (Responsive.isDesktop(context)) {
    spaceHeight = 30.0;
  } else if (Responsive.isTablet(context)) {
    spaceHeight = 20.0;
  } else {
    spaceHeight = 10.0;
  }

  final myTables = context.read<TablesPageViewModel>();

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shadowColor: Colors.yellow,
            backgroundColor: Colors.grey.shade800,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            title: Center(
              child: Column(
                children: [
                  Text('Masa Detay',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  SizedBox(height: spaceHeight),
                  Divider(
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            content: SingleChildScrollView(
              child: Container(
                width: SizeConstants.width * 0.3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: spaceHeight),
                    TextField(
                      controller: _titleController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Masa Numarası',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                    SizedBox(height: 1.5 * spaceHeight),
                    Text(
                      "Oluşturan: " + tableInfo.creative!,
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "Oluşturma Tarihi: " +
                          DateFormat('dd-MM-yyyy HH:mm')
                              .format(tableInfo.creationDate!.toDate()),
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "Son Değiştiren: " + tableInfo.lastModified!,
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "Son Değiştirme Tarihi: " +
                          DateFormat('dd-MM-yyyy HH:mm')
                              .format(tableInfo.lastModifiedDate!.toDate()),
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    Divider(
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('İptal', style: TextStyle(color: Colors.red)),
              ),
              ElevatedButton(
                onPressed: () {
                  Provider.of<TablesPageViewModel>(context, listen: false)
                      .deleteTable(tableInfo.tableID!)
                      .then((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Masa başarıyla silindi'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.of(context).pop();
                  }).catchError((error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Masa silinirken hata oluştu: $error'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // Button color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text('Sil'),
              ),
              Visibility(
                visible: false,
                child: ElevatedButton(
                  onPressed: () {
                    myTables
                        .updateTable(tableInfo.tableID!, "_selectedParentTable",
                            _titleController.text)
                        .then((_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Kategori başarıyla güncellendi'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.of(context).pop();
                    }).catchError((error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Kategori güncellenirken hata oluştu: $error'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Button color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Text('Kaydet'),
                ),
              )
            ],
          );
        },
      );
    },
  );
}
