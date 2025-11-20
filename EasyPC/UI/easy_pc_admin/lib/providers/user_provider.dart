import 'package:desktop/models/user.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String? _username;
  String? _password;
  User? _user;

  String? get username => _username;
  String? get password => _password;
  User? get user => _user;
  int? get userRole => _user?.role;

  bool get isLoggedIn => _username != null && _password != null;
  bool get isSuperAdmin => _user?.role == 3;

  void setCredentials(String username, String password) {
    _username = username;
    _password = password;
    notifyListeners();
  }

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }

  void clearCredentials() {
    _username = null;
    _password = null;
    _user = null;
    notifyListeners();
  }
}
