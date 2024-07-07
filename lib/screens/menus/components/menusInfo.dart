import 'dart:convert';
import 'package:admin/date_service.dart';
import 'package:admin/screens/menus/components/edit_menu_dialog.dart';
import 'package:flutter/material.dart';
import 'package:admin/models/MenusModel.dart';
import 'package:admin/responsive.dart';
import 'package:admin/screens/menus/menus_model_screen.dart'; // doğru dosya yolu kontrol edin
import 'package:image_picker_web/image_picker_web.dart';
import 'package:provider/provider.dart';
import '../../../constants.dart';
import 'package:firebase_storage/firebase_storage.dart';

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
      DataCell(Icon(Icons.image)),
      DataCell(ElevatedButton(
          onPressed: () {
            showDetailMenuDialog(menuInfo, context);
          },
          child: Text("İşlem")))
    ],
  );
}

void showAddMenuDialog(BuildContext context) async {
  final _productController = TextEditingController();
  final _contentController = TextEditingController();
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

  await Provider.of<MenusPageViewModel>(context, listen: false)
      .fetchCategories();
  final myMenus = context.read<MenusPageViewModel>();

  if (myMenus.categories.isNotEmpty) {
    _categories = myMenus
        .getFilteredCategories(_selectedParentCategory)
        .map((category) => category.name!)
        .toList();
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
                width: MediaQuery.of(context).size.width * 0.3,
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
                    Divider(
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
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
              if (_productController.text.isNotEmpty &&
                  _priceController.text.isNotEmpty &&
                  _selectedCategory != null) {
                String menuID = DateService().createEpoch(DateTime.now());
                String imageUrl =
                    await uploadImageToFirebase(selectedImageUrl!, menuID);
                // Verileri Firestore'a kaydet
                myMenus.addMenu(
                    _selectedParentCategory!,
                    _selectedCategory!,
                    _productController.text,
                    _contentController.text,
                    _priceController.text,
                    imageUrl,
                    menuID);
                Navigator.of(context).pop();
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
