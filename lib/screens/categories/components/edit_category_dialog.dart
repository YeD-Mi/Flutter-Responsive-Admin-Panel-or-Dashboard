import 'package:admin/constants.dart';
import 'package:admin/models/CategoriesModel.dart';
import 'package:admin/responsive.dart';
import 'package:admin/screens/categories/categories_model_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

Future<void> showDetailCategoryDialog(
    CategoriesModel categoryInfo, BuildContext context) async {
  final _nameController = TextEditingController();
  _nameController.text = categoryInfo.name!;

  double spaceHeight;
  if (Responsive.isDesktop(context)) {
    spaceHeight = 30.0;
  } else if (Responsive.isTablet(context)) {
    spaceHeight = 20.0;
  } else {
    spaceHeight = 10.0;
  }

  String? _selectedParentCategory = categoryInfo.parentCategory!;
  List<String> _parentCategories = ["Yiyecek", "İçecek"];

  final myCategories = context.read<CategoriesPageViewModel>();

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
                  Text('Kategori Düzenle',
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
                          _selectedParentCategory = newValue!;
                        });
                      },
                    ),
                    SizedBox(height: spaceHeight),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Kategori Adı',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                    SizedBox(height: 1.5 * spaceHeight),
                    Text(
                      "Oluşturan: " + categoryInfo.creative!,
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "Oluşturma Tarihi: " +
                          DateFormat('dd-MM-yyyy HH:mm')
                              .format(categoryInfo.creationDate!.toDate()),
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "Son Değiştiren: " + categoryInfo.lastModified!,
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "Son Değiştirme Tarihi: " +
                          DateFormat('dd-MM-yyyy HH:mm')
                              .format(categoryInfo.lastModifiedDate!.toDate()),
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
                  Provider.of<CategoriesPageViewModel>(context, listen: false)
                      .deleteCategory(categoryInfo.categoryID!)
                      .then((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Kategori başarıyla silindi'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.of(context).pop();
                  }).catchError((error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text('Kategori silinirken hata oluştu: $error'),
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
              ElevatedButton(
                onPressed: () {
                  myCategories
                      .updateCategory(categoryInfo.categoryID!,
                          _selectedParentCategory!, _nameController.text)
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
                        content:
                            Text('Kategori güncellenirken hata oluştu: $error'),
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
              )
            ],
          );
        },
      );
    },
  );
}
