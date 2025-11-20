import 'package:easy_pc/models/user.dart';
import 'package:easy_pc/services/secure_storage_service.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  User? _user;
  String? _password;

  User? get user => _user;
  String? get password => _password;

  Future<void> setUserWithPassword(User user, String password) async {
    _user = user;
    _password = password;

    if (user.username != null) {
      await SecureStorageService.saveCredentials(
        username: user.username!,
        password: password,
      );
    }

    notifyListeners();
  }

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }

  Future<void> loadPassword() async {
    if (_user?.username != null) {
      _password = await SecureStorageService.getPassword();
      notifyListeners();
    }
  }

  Future<void> clearUser() async {
    _user = null;
    _password = null;
    await SecureStorageService.clearCredentials();
    notifyListeners();
  }

  Future<bool> tryRestoreSession() async {
    final hasCredentials = await SecureStorageService.hasCredentials();
    if (hasCredentials) {
      _password = await SecureStorageService.getPassword();
      return true;
    }
    return false;
  }
}