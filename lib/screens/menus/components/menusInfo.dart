import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:admin/models/MenusModel.dart';
import 'package:admin/responsive.dart';
import 'package:admin/screens/Menus/Menus_model_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker_web/image_picker_web.dart';
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
                        _showAddMenuDialog(context);
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
                      myMenus.Menus.length,
                      (index) => menuInfoDataRow(myMenus.Menus[index], context),
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
      DataCell(Icon(Icons.image)),
      DataCell(ElevatedButton(
          onPressed: () {
            _showDetailMenuDialog(menuInfo, context);
          },
          child: Text("İşlem")))
    ],
  );
}

void _showAddMenuDialog(BuildContext context) {
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
                  "",
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

void _showDetailMenuDialog(MenusModel menuInfo, BuildContext context) {
  final _categoryController = TextEditingController();
  final _productController = TextEditingController();
  final _contentController = TextEditingController();
  final _priceController = TextEditingController();

  _productController.text = menuInfo.title!;
  _contentController.text = menuInfo.contents!;
  _priceController.text = menuInfo.price!;

  double horizontalMargin;
  if (Responsive.isDesktop(context)) {
    horizontalMargin = 450.0;
  } else if (Responsive.isTablet(context)) {
    horizontalMargin = 150.0;
  } else {
    horizontalMargin = 10.0;
  }

  double spaceHeight;
  if (Responsive.isDesktop(context)) {
    spaceHeight = 30.0;
  } else if (Responsive.isTablet(context)) {
    spaceHeight = 20.0;
  } else {
    spaceHeight = 10.0;
  }

  // Placeholder for the selected image URL
  String? selectedImageUrl = menuInfo.image;

  String? _selectedParentCategory = menuInfo.parentCategory!;
  List<String> _parentCategories = ["Yiyecek", "İçecek"];

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            title: Center(
              child: Column(
                children: [
                  Text('Menü Düzenle',
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: spaceHeight),
                  DropdownButtonFormField<String>(
                    value: _selectedParentCategory,
                    decoration: InputDecoration(
                      labelText: 'Üst Kategori',
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
                  SizedBox(height: spaceHeight),
                  TextField(
                    controller: _categoryController,
                    decoration: InputDecoration(
                      labelText: 'Kategori',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                  SizedBox(height: spaceHeight),
                  TextField(
                    controller: _productController,
                    decoration: InputDecoration(
                      labelText: 'Ürün',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                  SizedBox(height: spaceHeight),
                  TextField(
                    controller: _contentController,
                    maxLines: 3, // İçerik alanının üç satıra sığması için
                    decoration: InputDecoration(
                      labelText: 'İçerik',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                  SizedBox(height: spaceHeight),
                  TextField(
                    controller: _priceController,
                    decoration: InputDecoration(
                      labelText: 'Fiyat',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: spaceHeight),
                  // Image display and picker
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final image =
                                await ImagePickerWeb.getImageAsBytes();
                            if (image != null) {
                              setState(() {
                                selectedImageUrl = 'data:image/png;base64,' +
                                    base64Encode(image);
                              });
                            }
                          },
                          child: selectedImageUrl != null
                              ? Image.network(
                                  selectedImageUrl!,
                                  height: spaceHeight * 7,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  color: Colors.grey[300],
                                  child: Icon(Icons.add),
                                ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () async {
                          final image = await ImagePickerWeb.getImageAsBytes();
                          if (image != null) {
                            setState(() {
                              selectedImageUrl = 'data:image/png;base64,' +
                                  base64Encode(image);
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 1.5 * spaceHeight),
                  Text(
                    "Oluşturan: " + menuInfo.creative!,
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Oluşturma Tarihi: " +
                        menuInfo.creationDate!.toDate().toString(),
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Son Değiştiren: " + menuInfo.lastModified!,
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Son Değiştirme Tarihi: " +
                        menuInfo.lastModifiedDate!.toDate().toString(),
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  Divider(
                    color: Colors.white,
                  ),
                ],
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
                  // Implement save logic here
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // Button color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text('Kaydet'),
              ),
            ],
          );
        },
      );
    },
  );
}
