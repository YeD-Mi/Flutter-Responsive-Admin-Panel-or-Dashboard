import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:admin/responsive.dart';

import 'package:admin/screens/login/login_model_screen.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double horizontalMargin;

    if (Responsive.isDesktop(context)) {
      horizontalMargin = 550.0;
    } else if (Responsive.isTablet(context)) {
      horizontalMargin = 150.0;
    } else {
      horizontalMargin = 25.0;
    }

    final viewModel = Provider.of<LoginPageViewModel>(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFAB20B), Color(0xFF52C5D7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 5,
              margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/enjula-logo1.png',
                      height: 200,
                    ),
                    SizedBox(height: 25),
                    Text(
                      'Web Panel',
                      style: TextStyle(fontSize: 15, color: Colors.white),
                    ),
                    SizedBox(height: 25),
                    TextField(
                      controller: viewModel.emailController,
                      decoration: InputDecoration(
                        labelText: 'E-Mail',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: viewModel.passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Şifre',
                        prefixIcon: Icon(Icons.lock),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 25),
                    ElevatedButton(
                      onPressed: viewModel.state == LoginPageState.busy
                          ? null
                          : () async {
                              bool loginSuccess = await viewModel.login(
                                viewModel.emailController.text,
                                viewModel.passwordController.text,
                              );
                              if (loginSuccess) {
                                // authController.login() çağrısı zaten ViewModel'de yapılıyor.
                                // Bu nedenle burada ekstra bir işlem yapmamıza gerek yok.
                              } else if (viewModel.state ==
                                  LoginPageState.error) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(viewModel.errorMessage ??
                                        'An error occurred'),
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        backgroundColor: Color(0xFFFAB20B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        viewModel.state == LoginPageState.busy
                            ? 'Loading...'
                            : 'Giriş Yap',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
