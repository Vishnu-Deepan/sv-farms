import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static const String _keyIsLoggedIn = "isLoggedIn";
  static const String _keyUserId = "userId";
  static const String _keyEmail = "email";
  static const String _keyPhone = "phone";

  // Save user session data
  static Future<void> saveUserSession(String userId, String email, String phone) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(_keyIsLoggedIn, true);
    prefs.setString(_keyUserId, userId);
    prefs.setString(_keyEmail, email);
    prefs.setString(_keyPhone, phone);
  }

  // Get user session data
  static Future<Map<String, String?>> getUserSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString(_keyUserId);
    String? email = prefs.getString(_keyEmail);
    String? phone = prefs.getString(_keyPhone);
    return {
      'userId': userId,
      'email': email,
      'phone': phone,
    };
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  // Clear the session
  static Future<void> clearSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(_keyIsLoggedIn);
    prefs.remove(_keyUserId);
    prefs.remove(_keyEmail);
    prefs.remove(_keyPhone);
  }
}
