import 'dart:convert';

import 'package:admin/models/MenusModel.dart';
import 'package:admin/responsive.dart';
import 'package:flutter/material.dart';
import 'package:image_picker_web/image_picker_web.dart';

void showDetailMenuDialog(MenusModel menuInfo, BuildContext context) {
  final _categoryController = TextEditingController();
  final _productController = TextEditingController();
  final _contentController = TextEditingController();
  final _priceController = TextEditingController();

  _productController.text = menuInfo.title!;
  _contentController.text = menuInfo.contents!;
  _priceController.text = menuInfo.price!;

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
            shadowColor: Colors.yellow,
            backgroundColor: Colors.grey.shade800,
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
