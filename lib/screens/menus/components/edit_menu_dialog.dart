import 'dart:convert';
import 'package:admin/constants.dart';
import 'package:admin/models/MenusModel.dart';
import 'package:admin/responsive.dart';
import 'package:admin/screens/menus/menus_model_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

    // Kategoriler doluysa ve selectedCategory henüz atanmadıysa ilk öğeye ayarlayın
    if (_categories.isNotEmpty) {
      _selectedCategory = _categories.contains(menuInfo.category)
          ? menuInfo
              .category // Eğer veritabanından gelen kategori listede varsa, onu kullan
          : _categories.first; // Yoksa, ilk öğeye ayarlayın
    }
  }

  List<Map<String, String>> priceOptions = menuInfo.priceOptions?.map((option) {
        return {
          "type": option['type'] ?? "",
          "type_en": option['type_en'] ?? "",
          "price": option['price'] ?? ""
        };
      }).toList() ??
      [
        {"type": "", "type_en": "", "price": ""}
      ];

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
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20)),
                    SizedBox(height: spaceHeight),
                    Divider(
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
              content: SingleChildScrollView(
                child: Container(
                  width: SizeConstants.width * 0.5,
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
                      Row(
                        children: [
                          Icon(Icons.category, color: Colors.blue),
                          SizedBox(width: 8.0),
                          Text(
                            "Alt Kırılımlar:",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Spacer(),
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                priceOptions.add(
                                    {"type": "", "type_en": "", "price": ""});
                              });
                            },
                            icon: Icon(Icons.add),
                            label: Text("Yeni Kırılım"),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.blue, // Text color
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: spaceHeight / 2),
// Price Options Fields
                      ...priceOptions.asMap().entries.map((entry) {
                        int index = entry.key;
                        Map<String, String> option = entry.value;

                        return Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: TextEditingController(
                                        text: option['type']),
                                    decoration: InputDecoration(
                                      labelText: 'Açıklama',
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                    ),
                                    onChanged: (value) {
                                      option['type'] = value;
                                    },
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    controller: TextEditingController(
                                        text: option['type_en']),
                                    decoration: InputDecoration(
                                      labelText: 'Açıklama (English)',
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                    ),
                                    onChanged: (value) {
                                      option['type_en'] = value;
                                    },
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    controller: TextEditingController(
                                        text: option['price']),
                                    decoration: InputDecoration(
                                      labelText: 'Artı Fiyat',
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                    ),
                                    onChanged: (value) {
                                      option['price'] = value;
                                    },
                                  ),
                                ),
                                // Satır Silme Butonu
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    setState(() {
                                      priceOptions
                                          .removeAt(index); // Satırı sil
                                    });
                                  },
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                          ],
                        );
                      }).toList(),

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
                                    selectedImageUrl =
                                        'data:image/png;base64,' +
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
                Row(
                  mainAxisAlignment: MainAxisAlignment
                      .spaceBetween, // Butonlar arasında boşluk bırakır
                  children: [
                    // Sola yaslı Günün Yıldızı butonu
                    ElevatedButton(
                      onPressed: () {
                        Provider.of<MenusPageViewModel>(context, listen: false)
                            .updateStarDay(menuInfo.menuID!)
                            .then((_) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Günün yıldızı güncellendi.'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          Navigator.of(context).pop();
                        }).catchError((error) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Bir hata oluştu: $error'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow, // Buton rengi
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: Text(
                        'Günün Yıldızı Yap',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    // Diğer butonlar sağa yaslı
                    Row(
                      // Butonların dar alanda olmasını sağlar
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('İptal',
                              style: TextStyle(color: Colors.red)),
                        ),
                        SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            Provider.of<MenusPageViewModel>(context,
                                    listen: false)
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
                                  content: Text(
                                      'Menü silinirken hata oluştu: $error'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red, // Buton rengi
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          child: Text('Sil'),
                        ),
                        SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () async {
                            String? categoryNameEn =
                                await getCategoryNameEn(_selectedCategory!);
                            myMenus
                                .updateMenu(
                                    menuInfo.menuID!,
                                    _selectedParentCategory!,
                                    _selectedParentCategory!,
                                    _selectedCategory!,
                                    categoryNameEn ?? '',
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
                                  content: Text(
                                      'Menü güncellenirken hata oluştu: $error'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green, // Buton rengi
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          child: Text('Kaydet'),
                        ),
                      ],
                    ),
                  ],
                ),
              ]);
        },
      );
    },
  );
}

Future<String?> getCategoryNameEn(String categoryName) async {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  try {
    // 'categories' koleksiyonundan veriyi çek
    QuerySnapshot querySnapshot = await _firestore
        .collection('categories')
        .where('name', isEqualTo: categoryName)
        .get();

    // Sorgudan sonuç varsa, 'name_en' değerini al
    if (querySnapshot.docs.isNotEmpty) {
      DocumentSnapshot documentSnapshot = querySnapshot.docs.first;
      return documentSnapshot['name_en'] as String?;
    } else {
      return null; // Veriyi bulamazsa null döner
    }
  } catch (e) {
    print('Veri çekme hatası: $e');
    return null;
  }
}
