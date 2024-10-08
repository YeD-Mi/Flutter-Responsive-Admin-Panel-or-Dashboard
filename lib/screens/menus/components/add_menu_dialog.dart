import 'dart:convert';
import 'package:admin/constants.dart';
import 'package:admin/date_service.dart';
import 'package:admin/responsive.dart';
import 'package:admin/screens/menus/menus_model_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:provider/provider.dart';

void showAddMenuDialog(BuildContext context) async {
  final _productController = TextEditingController();
  final _productController_en = TextEditingController();
  final _contentController = TextEditingController();
  final _contentController_en = TextEditingController();
  final _priceController = TextEditingController();

  double spaceHeight;
  if (Responsive.isDesktop(context)) {
    spaceHeight = 30.0;
  } else if (Responsive.isTablet(context)) {
    spaceHeight = 20.0;
  } else {
    spaceHeight = 10.0;
  }

  String? selectedImageUrl = "https://waterstation.com.tr/img/default.jpg";

  String? _selectedParentCategory = "Yiyecek";
  List<String> _parentCategories = ["Yiyecek", "İçecek"];

  List<String> _categories = [];
  String? _selectedCategory;

  List<Map<String, String>> priceOptions = [{}]; // Başlangıçta bir boş alan

  await Provider.of<MenusPageViewModel>(context, listen: false)
      .fetchCategories();
  final myMenus = context.read<MenusPageViewModel>();

  if (myMenus.categories.isNotEmpty) {
    _categories = myMenus
        .getFilteredCategories(_selectedParentCategory)
        .map((category) => category.name!)
        .toList();
    _selectedCategory = _categories.first;
  }

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shadowColor: Colors.yellow,
        backgroundColor: Colors.grey.shade800,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        title: Center(
          child: Column(
            children: [
              Text(
                'Yeni Menü',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              SizedBox(height: spaceHeight),
              Divider(
                color: Colors.white,
              ),
            ],
          ),
        ),
        content: StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
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
                          _selectedCategory =
                              _categories.isNotEmpty ? _categories.first : null;
                        },
                      ),
                      SizedBox(height: spaceHeight),
                      DropdownButtonFormField<String>(
                        value: _categories.isNotEmpty ? _categories[0] : null,
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
                        maxLines: 3,
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
                        maxLines: 3,
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
                          labelText: 'Genel Fiyat',
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
                      ...priceOptions.map((option) {
                        return Row(
                          children: [
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  labelText: 'Açıklama',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
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
                                decoration: InputDecoration(
                                  labelText: 'Açıklama (English)',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
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
                                decoration: InputDecoration(
                                  labelText: 'Artı Fiyat',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                onChanged: (value) {
                                  option['price'] = value;
                                },
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                      SizedBox(height: spaceHeight),
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
                              child: Image.network(
                                selectedImageUrl!,
                                width: SizeConstants.width * 0.2,
                                height: SizeConstants.width * 0.2,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.add_a_photo),
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
                      SizedBox(height: spaceHeight),
                      Divider(
                        color: Colors.white,
                      ),
                      SizedBox(height: spaceHeight),
                    ],
                  )),
            );
          },
        ),
        actions: [
          TextButton(
            child: Text('İptal'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          ElevatedButton(
            child: Text('Ekle'),
            onPressed: () async {
              if (_productController.text.isEmpty ||
                  _priceController.text.isEmpty) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Uyarı'),
                      content: Text(
                          'Ürün ve fiyat alanları zorunludur. Lütfen doldurun.'),
                      actions: <Widget>[
                        TextButton(
                          child: Text('Tamam'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              } else if (_selectedCategory != null) {
                String menuID = DateService().createEpoch(DateTime.now());
                String imageUrl =
                    'https://firebasestorage.googleapis.com/v0/b/enjula-qrmenu.appspot.com/o/menu_images%2Fdefault_image.png?alt=media&token=d556b2d6-88be-47b7-9aae-eb8c6c95bae8';

                if (selectedImageUrl != null &&
                    selectedImageUrl !=
                        "https://waterstation.com.tr/img/default.jpg") {
                  imageUrl =
                      await uploadImageToFirebase(selectedImageUrl!, menuID);
                }

                // Veritabanından 'name_en' değerini al
                String? categoryNameEn =
                    await getCategoryNameEn(_selectedCategory!);

                // Verileri Firestore'a kaydet
                myMenus
                    .addNewMenuAndRefresh(
                        _selectedParentCategory!,
                        _selectedParentCategory!,
                        _selectedCategory!,
                        categoryNameEn ??
                            '', // Eğer name_en bulunamazsa boş string kullan
                        _productController.text,
                        _productController_en.text,
                        _contentController.text,
                        _contentController_en.text,
                        _priceController.text,
                        imageUrl,
                        menuID,
                        priceOptions)
                    .then((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Menü başarıyla eklendi'),
                      backgroundColor: Colors.green,
                    ),
                  );

                  Navigator.of(context).pop();
                }).catchError((error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Menü eklenirken hata oluştu: $error'),
                      backgroundColor: Colors.red,
                    ),
                  );
                });
              }
            },
          ),
        ],
      );
    },
  );
}

Future<String> uploadImageToFirebase(String imageUrl, String menuID) async {
  final storage = FirebaseStorage.instance;

  try {
    // Resmi base64'ten çözüp byte verisine dönüştür
    final decodedBytes = base64Decode(imageUrl.split(',').last);

    // Firebase Storage'a yükle
    final storageRef = storage.ref().child("menu_images/$menuID.png");
    final uploadTask = storageRef.putData(decodedBytes);
    await uploadTask.whenComplete(() {});

    // URL'yi al
    final downloadUrl = await storageRef.getDownloadURL();
    return downloadUrl;
  } catch (e) {
    print("Resim yükleme hatası: $e");
    return "";
  }
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
