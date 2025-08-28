import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesUtil {
  static const String _accessTokenKey = "ACCESS_TOKEN";
  static const String _selectedBusinessKey = 'selectedBusinessId';

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

  /// save onboarding seen status
  static Future<void> saveOnboardingStatus(bool isSeen) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_seen', isSeen);
  }

  /// get status of onboarding screens
  static Future<bool> isOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    print(prefs.getBool('onboarding_seen'));
    return prefs.getBool('onboarding_seen') ?? false;
  }

  /// Save selected business ID
  static Future<void> saveSelectedBusiness(String businessId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedBusinessKey, businessId);
  }

  /// Get selected business ID
  static Future<String?> getSelectedBusiness() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_selectedBusinessKey);
  }

  /// Clear selected business ID
  static Future<void> clearSelectedBusiness() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_selectedBusinessKey);
  }

  /// Get currently selected business ID with fallback to first shop
  static Future<String?> getCurrentShopId(List<dynamic> userShops) async {
    final selectedBusinessId = await getSelectedBusiness();

    if (selectedBusinessId != null && selectedBusinessId.isNotEmpty) {
      return selectedBusinessId;
    }

    // Fallback to first shop if no selection or empty shops
    if (userShops.isNotEmpty) {
      final fallbackId = userShops[0]["id"];
      // Save this as the selected business for future use
      if (fallbackId != null) {
        await saveSelectedBusiness(fallbackId);
      }
      return fallbackId;
    }

    return null;
  }
}
