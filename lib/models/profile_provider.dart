import 'package:flutter/material.dart';
import 'package:metia/data/user/Profile.dart';

class ProfileProvider extends ChangeNotifier {
  late Profile _user;
  Profile get user => _user;
  
  void setUser(Profile user){
    _user = user;
    notifyListeners();
  }
}
