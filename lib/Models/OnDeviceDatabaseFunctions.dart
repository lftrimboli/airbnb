import 'package:airbnb/Models/AppConstants.dart';
import 'package:airbnb/Models/Users.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserLoginFunctions {

  static const String emailKey = "email";
  static const String passwordKey = "password";
  static const String isCurrentlyHostingKey = "isCurrentlyHosting";

  static Future<User> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(emailKey);
    final password = prefs.getString(passwordKey);
    final isCurrentlyHosting = prefs.getBool(isCurrentlyHostingKey);
    if (email == null || password == null || isCurrentlyHosting == null) { return null; }
    User user = User();
    user.email = email;
    user.password = password;
    user.isCurrentlyHosting = isCurrentlyHosting;

    return user;
  }

  static void saveUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(emailKey, AppConstants.currentUser.email);
    prefs.setString(passwordKey, AppConstants.currentUser.password);
    prefs.setBool(isCurrentlyHostingKey, AppConstants.currentUser.isCurrentlyHosting);

    print("Saving...");
    print("Email: ${AppConstants.currentUser.email}");
    print("Password: ${AppConstants.currentUser.password}");
    print("Is hosting: ${AppConstants.currentUser.isCurrentlyHosting}");
  }

  static void clearUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

}