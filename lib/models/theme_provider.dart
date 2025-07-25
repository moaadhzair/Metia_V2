import 'package:flutter/material.dart';
import 'package:metia/colors/material_theme.dart';

class ThemeProvider extends ChangeNotifier {
  ColorScheme _scheme = MaterialTheme.darkScheme();
  ColorScheme get scheme => _scheme;
  bool isDarkMode = true;
  bool isLightMode = false;

  void setLightMode() {
    isDarkMode = false;
    isLightMode = true;
    _scheme = MaterialTheme.lightScheme();
    notifyListeners();
  }

  void setDarkMode() {
    isDarkMode = true;
    isLightMode = false;
    _scheme = MaterialTheme.darkScheme();
    notifyListeners();
  }
}
