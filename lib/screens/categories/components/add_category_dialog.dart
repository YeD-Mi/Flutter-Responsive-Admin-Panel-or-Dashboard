import 'package:admin/constants.dart';
import 'package:admin/date_service.dart';
import 'package:admin/responsive.dart';
import 'package:admin/screens/categories/categories_model_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void showAddCategoryDialog(BuildContext context) async {
  final _nameController = TextEditingController();

  double spaceHeight;
  if (Responsive.isDesktop(context)) {
    spaceHeight = 30.0;
  } else if (Responsive.isTablet(context)) {
    spaceHeight = 20.0;
  } else {
    spaceHeight = 10.0;
  }

  String? _selectedParentCategory = "Yiyecek";
  List<String> _parentCategories = ["Yiyecek", "İçecek"];

  final myCategories = context.read<CategoriesPageViewModel>();

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
                'Yeni Kategori',
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
                width: SizeConstants.width * 0.3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: spaceHeight),
                    DropdownButtonFormField<String>(
                      value: _selectedParentCategory,
                      decoration: InputDecoration(
                        labelText: 'Kategori Adı',
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
                        labelText: 'Ürün',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                    SizedBox(height: spaceHeight),
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
              if (_nameController.text.isEmpty) {
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
              } else {
                String categoryID = DateService().createEpoch(DateTime.now());

                // Verileri Firestore'a kaydet
                myCategories
                    .addNewCategoryAndRefresh(
                  _selectedParentCategory!,
                  _nameController.text,
                  categoryID,
                )
                    .then((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Kategori başarıyla eklendi'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.of(context).pop();
                }).catchError((error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Kategori eklenirken hata oluştu: $error'),
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
