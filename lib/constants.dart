import 'package:admin/models/UsersModel.dart';
import 'package:flutter/material.dart';

const primaryColor = Color(0xFF2697FF);
const secondaryColor = Color(0xFF2A2D3E);
const bgColor = Color(0xFF212332);

const defaultPadding = 16.0;

UsersModel? currentUser;
String? currentUserID;

class SizeConstants {
  static double _width = 1080;
  static double _height = 1920;

  static double get width => _width;
  static double get height => _height;

  static void updateSizes(double newWidth, double newHeight) {
    _width = newWidth;
    _height = newHeight;
  }
}
