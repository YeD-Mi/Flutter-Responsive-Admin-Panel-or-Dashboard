import 'package:admin/models/UsersModel.dart';
import 'package:admin/personelLocale.dart';
import 'package:admin/constants.dart';
import 'package:admin/firebase_options.dart';
import 'package:admin/providers.dart';
import 'package:admin/screens/login/login_model_screen.dart';
import 'package:admin/screens/login/login_screen.dart';
import 'package:admin/screens/main/main_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
      providers: providers,
      child: Consumer<LoginPageViewModel>(
        builder: (context, loginViewModel, _) {
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
            home: FutureBuilder<String?>(
              future: PersonalLocale().getCurrentUserID(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  var size = MediaQuery.of(context).size;
                  SizeConstants.updateSizes(size.width, size.height);

                  return snapshot.data?.isEmpty ?? true
                      ? LoginScreen()
                      : GoHomeScreen(userID: snapshot.data!);
                }
              },
            ),
          );
        },
      ),
    );
  }
}

class GoHomeScreen extends StatelessWidget {
  final String userID;

  GoHomeScreen({required this.userID});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UsersModel?>(
      future: getPersonalByID(userID),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          return MainScreen();
        }
      },
    );
  }

  Future<UsersModel?> getPersonalByID(String userID) async {
    final personalRef = FirebaseFirestore.instance.collection('users');
    final querySnapshot =
        await personalRef.where('userID', isEqualTo: userID).get();
    if (querySnapshot.docs.isEmpty) {
      return null;
    } else {
      final personalDoc = querySnapshot.docs.first;
      currentUser = UsersModel.fromJson(personalDoc.data());
      return currentUser;
    }
  }
}
