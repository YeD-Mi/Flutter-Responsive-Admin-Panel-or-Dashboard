import 'package:admin/controllers/MenuAppController.dart';
import 'package:admin/responsive.dart';
import 'package:admin/screens/categories/categories_screen.dart';
import 'package:admin/screens/dashboard/dashboard_screen.dart';
import 'package:admin/screens/menus/menus_screen.dart';
import 'package:admin/screens/tables/tables_screen.dart';
import 'package:admin/screens/orders/orders_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'components/side_menu.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedMenuItem = 0; // Varsayılan olarak ana sayfa seçili

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: context.read<MenuAppController>().scaffoldKey,
      drawer: SideMenu(
        onMenuItemSelected: (int index) {
          setState(() {
            selectedMenuItem = index;
          });
        },
      ),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // We want this side menu only for large screen
            if (Responsive.isDesktop(context))
              Expanded(
                // default flex = 1
                // and it takes 1/6 part of the screen
                child: SideMenu(
                  onMenuItemSelected: (int index) {
                    setState(() {
                      selectedMenuItem = index;
                    });
                  },
                ),
              ),
            Expanded(
              // It takes 5/6 part of the screen
              flex: 5,
              child: _buildSelectedScreen(selectedMenuItem),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedScreen(int selectedMenuItem) {
    switch (selectedMenuItem) {
      case 0:
        return DashboardScreen();
      case 1:
        return OrdersScreen();
      case 2:
        return TablesScreen();
      case 3:
        return CategoriesScreen();
      case 4:
        return MenusScreen();
      // Diğer ekranlar için case'ler ekleyin
      default:
        return DashboardScreen(); // Varsayılan olarak ana sayfa
    }
  }
}
