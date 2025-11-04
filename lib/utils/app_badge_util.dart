import 'dart:io';

class AppBadgeUtil {
  static int _count = 0;

  static Future<void> setCount(int count) async {
    _count = count.clamp(0, 9999);
    // No-op without plugin; for iOS, APNs badge is managed by server payload.
    // For Android, some launchers reflect notification count automatically.
  }

  static int get count => _count;

  static Future<void> increment() async {
    await setCount(_count + 1);
  }

  static Future<void> clear() async {
    await setCount(0);
  }
}
