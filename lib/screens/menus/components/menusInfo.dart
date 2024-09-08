import 'package:admin/date_service.dart';
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
  late Future<void> _fetchCategoriesFuture;
  String _selectedCategory = 'Hepsi'; // Default category
  List<String> _categories = []; // Ensure this is a List<String>

  @override
  void initState() {
    super.initState();
    final viewModel = Provider.of<MenusPageViewModel>(context, listen: false);
    _fetchMenusFuture = viewModel.fetchMenus();
    _fetchCategoriesFuture = viewModel.fetchCategories().then((_) {
      setState(() {
        // Convert List<CategoriesModel> to List<String> without nulls
        _categories = ['Hepsi'] +
            viewModel.categories
                .map((cat) =>
                    cat.name ??
                    '') // Replace null with empty string or handle null values as needed
                .where((name) =>
                    name.isNotEmpty) // Ensure no empty strings are included
                .toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<MenusPageViewModel>(context);
    return FutureBuilder(
      future: Future.wait([_fetchMenusFuture, _fetchCategoriesFuture]),
      builder: (context, snapshot) {
        if (viewModel.state == MenusPageState.busy) {
          return Center(child: CircularProgressIndicator());
        } else if (viewModel.state == MenusPageState.error) {
          return Center(child: Text('Error loading data'));
        } else {
          // Filter menus based on selected category
          List<MenusModel> filteredMenus = viewModel.menus.where((menu) {
            return _selectedCategory == 'Hepsi' ||
                menu.category == _selectedCategory;
          }).toList();

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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Dropdown Button for category filter
                    DropdownButton<String>(
                      value: _selectedCategory,
                      items: _categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedCategory = newValue!;
                        });
                      },
                    ),
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
                      DataColumn(label: Text("Kategori")),
                      DataColumn(label: Text("Ürün")),
                      DataColumn(label: Text("Fiyat")),
                      DataColumn(label: Text("Görsel")),
                      DataColumn(label: Text("Son Değişiklik")),
                      DataColumn(label: Text(" ")),
                    ],
                    rows: List.generate(
                      filteredMenus.length,
                      (index) => menuInfoDataRow(filteredMenus[index], context),
                    ),
                  ),
                ),
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
      DataCell(Text(DateService()
          .convertTimeStampYearHoursFormat(menuInfo.lastModifiedDate!))),
      DataCell(ElevatedButton(
          onPressed: () {
            showDetailMenuDialog(menuInfo, context);
          },
          child: Text("İşlem")))
    ],
  );
}
