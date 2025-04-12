import 'package:flutter/material.dart';

class AuthProviderData extends ChangeNotifier {
  static bool _showPassword = true;
  static bool _isLoading = false;

  bool get showPassword => _showPassword;

  void setShowPassword(bool value) {
    _showPassword = value;
    notifyListeners();
  }

  bool get isLoading => _isLoading;

  void setIsLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
