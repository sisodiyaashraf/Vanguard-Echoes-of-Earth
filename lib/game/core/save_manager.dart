import 'package:shared_preferences/shared_preferences.dart';
import 'package:vanguard_echoes_of_earth/game/progression/hero_progress.dart';

class SaveManager {
  static SharedPreferences? _prefs;
  static final Map<String, HeroProgress> _progressCache = {};

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Completed Levels
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

  static int getCompletedLevelsCount() {
    final completed = _prefs?.getStringList('completed_levels') ?? [];
    return completed.length;
  }

  // Backstories
  static Future<void> saveUnlockedBackstory(String heroId, int unlockedCount) async {
    await _prefs?.setInt('backstory_$heroId', unlockedCount);
  }

  static int getUnlockedBackstoryCount(String heroId) {
    return _prefs?.getInt('backstory_$heroId') ?? 0;
  }

  // Settings Volume
  static Future<void> saveBgmVolume(double vol) async {
    await _prefs?.setDouble('bgm_volume', vol);
  }

  static double getBgmVolume() {
    return _prefs?.getDouble('bgm_volume') ?? 0.7;
  }

  static Future<void> saveSfxVolume(double vol) async {
    await _prefs?.setDouble('sfx_volume', vol);
  }

  static double getSfxVolume() {
    return _prefs?.getDouble('sfx_volume') ?? 0.7;
  }

  // Tutorials
  static Future<void> setHasSeenTutorial(bool value) async {
    await _prefs?.setBool('has_seen_tutorial', value);
  }

  static bool hasSeenTutorial() {
    return _prefs?.getBool('has_seen_tutorial') ?? false;
  }

  static Future<void> setHasSeenTeamTutorial(bool value) async {
    await _prefs?.setBool('has_seen_team_tutorial', value);
  }

  static bool hasSeenTeamTutorial() {
    return _prefs?.getBool('has_seen_team_tutorial') ?? false;
  }

  // ==========================================
  // PROGRESSION & UPGRADE PERSISTENCE
  // ==========================================

  // Hero Progression
  static HeroProgress getHeroProgress(String heroId) {
    final cleanId = heroId.toLowerCase().replaceAll(' ', '_');
    if (_progressCache.containsKey(cleanId)) {
      return _progressCache[cleanId]!;
    }

    final xp = _prefs?.getInt('hero_${cleanId}_xp') ?? 0;
    final level = _prefs?.getInt('hero_${cleanId}_level') ?? 1;
    final skillPoints = _prefs?.getInt('hero_${cleanId}_skill_points') ?? 0;
    final skills = _prefs?.getStringList('hero_${cleanId}_skills') ?? [];

    final progress = HeroProgress(
      heroId: cleanId,
      xp: xp,
      level: level,
      skillPoints: skillPoints,
      unlockedSkillIds: skills,
    );
    _progressCache[cleanId] = progress;
    return progress;
  }

  static Future<void> saveHeroProgress(HeroProgress progress) async {
    final cleanId = progress.heroId.toLowerCase().replaceAll(' ', '_');
    _progressCache[cleanId] = progress;
    await _prefs?.setInt('hero_${cleanId}_xp', progress.xp);
    await _prefs?.setInt('hero_${cleanId}_level', progress.level);
    await _prefs?.setInt('hero_${cleanId}_skill_points', progress.skillPoints);
    await _prefs?.setStringList('hero_${cleanId}_skills', progress.unlockedSkillIds);
  }

  // Achievements
  static List<String> getUnlockedAchievements() {
    return _prefs?.getStringList('unlocked_achievements') ?? [];
  }

  static Future<void> saveUnlockedAchievements(List<String> list) async {
    await _prefs?.setStringList('unlocked_achievements', list);
  }

  static int getEnemyDeaths() {
    return _prefs?.getInt('enemy_deaths') ?? 0;
  }

  static Future<void> saveEnemyDeaths(int deaths) async {
    await _prefs?.setInt('enemy_deaths', deaths);
  }

  // Daily Challenge
  static String getLastChallengeDate() {
    return _prefs?.getString('last_challenge_date') ?? '';
  }

  static Future<void> saveLastChallengeDate(String dateStr) async {
    await _prefs?.setString('last_challenge_date', dateStr);
  }

  static String getCurrentChallengeId() {
    return _prefs?.getString('current_challenge_id') ?? 'defeat_20_enemies';
  }

  static Future<void> saveCurrentChallengeId(String challengeId) async {
    await _prefs?.setString('current_challenge_id', challengeId);
  }

  static int getDailyChallengeProgress() {
    return _prefs?.getInt('daily_challenge_progress') ?? 0;
  }

  static Future<void> saveDailyChallengeProgress(int progress) async {
    await _prefs?.setInt('daily_challenge_progress', progress);
  }

  static bool isDailyChallengeCompleted() {
    return _prefs?.getBool('daily_challenge_completed') ?? false;
  }

  static Future<void> setDailyChallengeCompleted(bool value) async {
    await _prefs?.setBool('daily_challenge_completed', value);
  }

  static String getLastPlayedHeroId() {
    return _prefs?.getString('last_played_hero_id') ?? 'dragon';
  }

  static Future<void> saveLastPlayedHeroId(String heroId) async {
    await _prefs?.setString('last_played_hero_id', heroId.toLowerCase());
  }
}
