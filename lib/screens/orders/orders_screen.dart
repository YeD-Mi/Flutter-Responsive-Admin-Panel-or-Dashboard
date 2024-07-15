import 'package:admin/responsive.dart';
import 'package:admin/screens/orders/components/ordersInfo.dart';
import 'package:flutter/material.dart';
import '../../constants.dart';
import 'components/header.dart';

class OrdersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        primary: false,
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            Header(),
            SizedBox(height: defaultPadding),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      SizedBox(height: defaultPadding),
                      Ordersinfo(),
                      if (Responsive.isMobile(context))
                        SizedBox(height: defaultPadding)
                    ],
                  ),
                ),
                if (!Responsive.isMobile(context))
                  SizedBox(width: defaultPadding),
                // Ekran boyutuna göre ek bileşenler eklenebilir
              ],
            )
          ],
        ),
      ),
    );
  }
}
