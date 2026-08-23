class AppLocalizations {
  static final Map<String, String> _localizedStrings = {
    // Menu labels
    'menu_title': 'VANGUARD',
    'menu_subtitle': 'ECHOES OF EARTH',
    'menu_play': 'PLAY',
    'menu_achievements': 'ACHIEVEMENTS',
    'menu_settings': 'SETTINGS',
    'menu_quit': 'QUIT',
    'menu_boss_rush': 'BOSS RUSH',
    'menu_survival': 'SURVIVAL',
    'menu_locked': 'LOCKED',

    // Settings screen
    'settings_title': 'SETTINGS',
    'settings_music_volume': 'MUSIC VOLUME',
    'settings_sfx_volume': 'SFX VOLUME',
    'settings_accessibility': 'ACCESSIBILITY OPTIONS',
    'settings_high_contrast': 'HIGH-CONTRAST EFFECTS',
    'settings_larger_text': 'LARGER TEXT',
    'settings_left_handed': 'LEFT-HANDED CONTROLS',
    'settings_reset_data': 'RESET ALL DATA',
    'settings_back_to_menu': 'BACK TO MENU',
    'settings_reset_success': 'All progress has been reset successfully!',

    // Skill tree screen
    'skills_title': 'SKILLS & UPGRADES',
    'skills_points': 'SKILL POINTS AVAILABLE',
    'skills_choose_hero': 'SELECT HERO',
    'skills_locked_node': 'LOCKED',
    'skills_unlocked_node': 'UNLOCKED',
    'skills_unlock_btn': 'UNLOCK',
    'skills_points_short': 'SP',

    // Achievements screen
    'achievements_title': 'ACHIEVEMENTS',
    'achievements_locked': 'LOCKED',
    'achievements_unlocked': 'UNLOCKED',

    // Overlay results
    'clear_mission_clear': 'MISSION CLEAR',
    'clear_failed': 'MISSION FAILED',
    'clear_retry': 'RETRY',
    'clear_level_select': 'LEVEL SELECT',
    'clear_back_to_menu': 'BACK TO MENU',
    'clear_next_level': 'NEXT LEVEL',
    'clear_challenge_complete': 'CHALLENGE COMPLETE!',
    'clear_time': 'TIME',
    'clear_best_time': 'BEST',
    'clear_waves': 'WAVES SURVIVED',
    'clear_kills': 'ENEMIES DEFEATED',
  };

  static String translate(String key) {
    return _localizedStrings[key] ?? key;
  }
}
