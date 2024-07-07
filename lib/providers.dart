import 'package:admin/controllers/MenuAppController.dart';
import 'package:admin/screens/categories/categories_model_screen.dart';
import 'package:admin/screens/login/login_model_screen.dart';
import 'package:admin/screens/menus/menus_model_screen.dart';
import 'package:admin/screens/tables/tables_model_screen.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

List<SingleChildWidget> providers = [
  ChangeNotifierProvider(
    create: (context) => MenusPageViewModel(),
  ),
  ChangeNotifierProvider(
    create: (context) => MenuAppController(),
  ),
  ChangeNotifierProvider(
    create: (context) => TablesPageViewModel(),
  ),
  ChangeNotifierProvider(
    create: (context) => CategoriesPageViewModel(),
  ),
  ChangeNotifierProvider(
    create: (context) => LoginPageViewModel(),
  ),
];
