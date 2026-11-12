import 'package:flutter/material.dart';
import 'package:ridlers/index.dart';

class SystemBloc with ChangeNotifier {
  String token = '';
  String errorMessage = '';
  UserModel user = UserModel();

  String phone = '';
  String displayName = '';
  bool isAuthenticated = false;

  void updateUser(dynamic newUser) {
    try {
      debugPrint("Updating user with data:: $newUser");
      user = UserModel.fromJson(newUser);
      debugPrint("User updated successfully: ${user.toJson()}");
    } catch (e) {
      debugPrint("Error printing newUser: $e");
    }
    debugPrint("User updated: Notifying listeners");
    notifyListeners();
  }

  void updateToken(String newToken) {
    token = newToken;
    notifyListeners();
  }

  void updateErrorMessage(String newErrorMessage) {
    errorMessage = newErrorMessage;
    notifyListeners();
  }

  void updateUserPhone(String newPhone, String? newName) {
    phone = newPhone;
    if (newName != null && newName.isNotEmpty) {
      displayName = newName;
    }
    isAuthenticated = true;
    notifyListeners();
  }

  void clearData() {
    token = '';
    errorMessage = '';
    user = UserModel();
    phone = '';
    displayName = '';
    isAuthenticated = false;
    notifyListeners();
  }
}
