import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SideMenu extends StatelessWidget {
  final Function(int) onMenuItemSelected;
  const SideMenu({
    Key? key,
    required this.onMenuItemSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            child: Image.asset("assets/images/enjula-logo1.png"),
          ),
          DrawerListTile(
            title: "Ana Sayfa",
            svgSrc: "assets/icons/menu_dashboard.svg",
            press: () {
              onMenuItemSelected(0);
            },
          ),
          DrawerListTile(
            title: "Siparişler",
            svgSrc: "assets/icons/menu_dashboard.svg",
            press: () {
              onMenuItemSelected(1);
            },
          ),
          DrawerListTile(
            title: "Masalar",
            svgSrc: "assets/icons/menu_tran.svg",
            press: () {
              onMenuItemSelected(2);
            },
          ),
          DrawerListTile(
            title: "Kategoriler",
            svgSrc: "assets/icons/menu_task.svg",
            press: () {
              onMenuItemSelected(3);
            },
          ),
          DrawerListTile(
            title: "Menüler",
            svgSrc: "assets/icons/menu_doc.svg",
            press: () {
              onMenuItemSelected(4);
            },
          ),
          DrawerListTile(
            title: "Profil",
            svgSrc: "assets/icons/menu_store.svg",
            press: () {
              onMenuItemSelected(5);
            },
          ),
          DrawerListTile(
            title: "Ayarlar",
            svgSrc: "assets/icons/menu_setting.svg",
            press: () {
              onMenuItemSelected(6);
            },
          ),
        ],
      ),
    );
  }
}

class DrawerListTile extends StatelessWidget {
  const DrawerListTile({
    Key? key,
    // For selecting those three line once press "Command+D"
    required this.title,
    required this.svgSrc,
    required this.press,
  }) : super(key: key);

  final String title, svgSrc;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: press,
      horizontalTitleGap: 0.0,
      leading: SvgPicture.asset(
        svgSrc,
        colorFilter: ColorFilter.mode(Colors.white54, BlendMode.srcIn),
        height: 16,
      ),
      title: Text(
        title,
        style: TextStyle(color: Colors.white54),
      ),
    );
  }
}
