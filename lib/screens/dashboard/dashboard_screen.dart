import 'package:admin/responsive.dart';
import 'package:admin/screens/dashboard/components/my_fields.dart';
import 'package:admin/screens/dashboard/dasboard_model_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Provider'ı ekliyoruz
import '../../constants.dart';
import 'components/header.dart';
import 'components/son_siparisler.dart';
import 'components/sag_sidebar.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DashboardPageViewModel()
        ..fetchLastOrders(), // fetchLastOrders burada başlatılıyor
      child: SafeArea(
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
                        MyFiles(), // MyFiles artık doğru ViewModel'i alıyor
                        SizedBox(height: defaultPadding),
                        RecentFiles(
                          viewModel: DashboardPageViewModel(),
                        ),
                        if (Responsive.isMobile(context))
                          SizedBox(height: defaultPadding),
                        if (Responsive.isMobile(context)) StorageDetails(),
                      ],
                    ),
                  ),
                  if (!Responsive.isMobile(context))
                    SizedBox(width: defaultPadding),
                  if (!Responsive.isMobile(context))
                    Expanded(
                      flex: 2,
                      child: StorageDetails(),
                    ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
