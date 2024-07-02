import 'package:admin/authController.dart';
import 'package:admin/constants.dart';
import 'package:admin/controllers/MenuAppController.dart';
import 'package:admin/firebase_options.dart';
import 'package:admin/screens/Menus/Menus_model_screen.dart';
import 'package:admin/screens/categories/categories_model_screen.dart';
import 'package:admin/screens/login/login_model_screen.dart';
import 'package:admin/screens/login/login_screen.dart';
import 'package:admin/screens/tables/tables_model_screen.dart';
import 'package:admin/screens/main/main_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AuthController(),
        ),
        ChangeNotifierProxyProvider<AuthController, LoginPageViewModel>(
          create: (context) => LoginPageViewModel(
              Provider.of<AuthController>(context, listen: false)),
          update: (context, authController, loginPageViewModel) =>
              LoginPageViewModel(authController),
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
          create: (context) => MenusPageViewModel(),
        ),
      ],
      child: Consumer<AuthController>(
        builder: (context, authController, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Flutter Admin Panel',
            theme: ThemeData.dark().copyWith(
              scaffoldBackgroundColor: bgColor,
              textTheme:
                  GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme)
                      .apply(bodyColor: Colors.white),
              canvasColor: secondaryColor,
            ),
            home: authController.isLoggedIn
                ? MainScreen()
                : LoginScreen(), // Kullanıcı durumuna göre ekranı belirliyoruz
          );
        },
      ),
    );
  }
}
