import 'dart:convert';
import 'package:admin/constants.dart';
import 'package:admin/models/MenusModel.dart';
import 'package:admin/responsive.dart';
import 'package:admin/screens/menus/menus_model_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

Future<void> showDetailMenuDialog(
    MenusModel menuInfo, BuildContext context) async {
  final _productController = TextEditingController();
  final _productController_en = TextEditingController();
  final _contentController = TextEditingController();
  final _contentController_en = TextEditingController();
  final _priceController = TextEditingController();

  _productController.text = menuInfo.title!;
  _productController_en.text = menuInfo.title_en!;
  _contentController.text = menuInfo.contents!;
  _contentController_en.text = menuInfo.contents_en!;
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

  List<Map<String, String>> priceOptions = [{}]; // Başlangıçta bir boş alan

  String? _selectedCategory;
  List<String> _categories = [];

  await Provider.of<MenusPageViewModel>(context, listen: false)
      .fetchCategories();
  final myMenus = context.read<MenusPageViewModel>();

  if (myMenus.categories.isNotEmpty) {
    _categories = myMenus
        .getFilteredCategories(_selectedParentCategory)
        .map((category) => category.name!)
        .toList();
    _selectedCategory = menuInfo.category;
  }

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

                          _categories = myMenus
                              .getFilteredCategories(_selectedParentCategory!)
                              .map((category) => category.name!)
                              .toList();
                        });
                        _selectedCategory = _categories.first;
                      },
                    ),
                    SizedBox(height: spaceHeight),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: InputDecoration(
                        labelText: 'Kategori',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      items: _categories.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedCategory = newValue;
                        });
                      },
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
                      controller: _productController_en,
                      decoration: InputDecoration(
                        labelText: 'Ürün (English)',
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
                      controller: _contentController_en,
                      maxLines: 3, // İçerik alanının üç satıra sığması için
                      decoration: InputDecoration(
                        labelText: 'İçerik (English)',
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
                                    width: SizeConstants.width * 0.2,
                                    height: SizeConstants.width * 0.2,
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
                            final image =
                                await ImagePickerWeb.getImageAsBytes();
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
                          DateFormat('dd-MM-yyyy HH:mm')
                              .format(menuInfo.creationDate!.toDate()),
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
                          DateFormat('dd-MM-yyyy HH:mm')
                              .format(menuInfo.lastModifiedDate!.toDate()),
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
                  Provider.of<MenusPageViewModel>(context, listen: false)
                      .deleteMenu(menuInfo.menuID!)
                      .then((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Menü başarıyla silindi'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.of(context).pop();
                  }).catchError((error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Menü silinirken hata oluştu: $error'),
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
                  myMenus
                      .updateMenu(
                          menuInfo.menuID!,
                          _selectedParentCategory!,
                          _selectedParentCategory!,
                          _selectedCategory!,
                          _selectedCategory!,
                          _productController.text,
                          _productController_en.text,
                          _contentController.text,
                          _contentController_en.text,
                          _priceController.text,
                          selectedImageUrl!,
                          priceOptions)
                      .then((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Menü başarıyla güncellendi'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.of(context).pop();
                  }).catchError((error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text('Menü güncellenirken hata oluştu: $error'),
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
