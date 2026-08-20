import 'package:shared_preferences/shared_preferences.dart';

class SaveManager {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> saveCompletedLevel(String levelId) async {
    final completed = _prefs?.getStringList('completed_levels') ?? [];
    if (!completed.contains(levelId)) {
      completed.add(levelId);
      await _prefs?.setStringList('completed_levels', completed);
    }
  }

  static bool isLevelCompleted(String levelId) {
    final completed = _prefs?.getStringList('completed_levels') ?? [];
    return completed.contains(levelId);
  }

  static Future<void> saveUnlockedBackstory(String heroId, int unlockedCount) async {
    await _prefs?.setInt('backstory_$heroId', unlockedCount);
  }

  static int getUnlockedBackstoryCount(String heroId) {
    return _prefs?.getInt('backstory_$heroId') ?? 0;
  }
}
