import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesUtil {
  static const String _accessTokenKey = "ACCESS_TOKEN";

  /// Save access token
  static Future<void> storeAccessToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, token);
  }

  /// Get access token
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  /// Remove access token
  static Future<void> removeAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
  }

  static Future<void> saveOnboardingStatus(bool isSeen) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_seen', isSeen);
  }

  static Future<bool> isOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    print(prefs.getBool('onboarding_seen'));
    return prefs.getBool('onboarding_seen') ?? false;
  }
}
