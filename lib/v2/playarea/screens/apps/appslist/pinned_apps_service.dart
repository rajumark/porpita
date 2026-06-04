import 'package:shared_preferences/shared_preferences.dart';

class PinnedAppsService {
  static const _key = 'pinned_apps';

  static Future<Set<String>> loadPinnedApps() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key)?.toSet() ?? {};
  }

  static Future<void> savePinnedApps(Set<String> pinnedApps) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, pinnedApps.toList());
  }

  static Future<void> togglePin(String packageName) async {
    final pinnedApps = await loadPinnedApps();
    if (pinnedApps.contains(packageName)) {
      pinnedApps.remove(packageName);
    } else {
      pinnedApps.add(packageName);
    }
    await savePinnedApps(pinnedApps);
  }

  static Future<bool> isPinned(String packageName) async {
    final pinnedApps = await loadPinnedApps();
    return pinnedApps.contains(packageName);
  }
}
