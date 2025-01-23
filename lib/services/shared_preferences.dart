import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static const _keyIsLoggedIn = 'isLoggedIn';
  static const _keyUserId = 'logged_in_user_id';

  /// Save login state
  Future<void> saveUserLoginState(bool isLoggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, isLoggedIn);
  }

  /// Get login state
  Future<bool> getUserLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false; // Default to false
  }

  /// Save user session by storing user ID
  Future<void> saveUserSession(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyUserId, userId);
  }

  
  /// Retrieve user session (user ID)
  Future<int?> getUserSession() async {
    
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyUserId);
  }

  /// Clear all session data
  Future<void> clearUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keyUserId);
  }
}
