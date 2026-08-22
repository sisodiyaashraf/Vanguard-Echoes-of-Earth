class Achievement {
  final String id;
  final String title;
  final String description;
  bool unlocked;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    this.unlocked = false,
  });

  static List<Achievement> getAchievements({List<String> unlockedIds = const []}) {
    return [
      Achievement(
        id: 'first_level',
        title: 'FIRST BLOOD',
        description: 'Complete your first level.',
        unlocked: unlockedIds.contains('first_level'),
      ),
      Achievement(
        id: 'defeat_50',
        title: 'HOLLOW SLAYER',
        description: 'Defeat 50 enemies.',
        unlocked: unlockedIds.contains('defeat_50'),
      ),
      Achievement(
        id: 'defeat_150',
        title: 'HOLLOW ERADICATOR',
        description: 'Defeat 150 enemies.',
        unlocked: unlockedIds.contains('defeat_150'),
      ),
      Achievement(
        id: 'reach_level_5',
        title: 'VANGUARD RECRUIT',
        description: 'Reach level 5 with any hero.',
        unlocked: unlockedIds.contains('reach_level_5'),
      ),
      Achievement(
        id: 'reach_level_10',
        title: 'VANGUARD ELITE',
        description: 'Reach level 10 with any hero.',
        unlocked: unlockedIds.contains('reach_level_10'),
      ),
      Achievement(
        id: 'dragon_clear',
        title: 'LORD OF FLAMES',
        description: 'Complete all of Dragon\'s levels.',
        unlocked: unlockedIds.contains('dragon_clear'),
      ),
      Achievement(
        id: 'all_bosses',
        title: 'SCOURGE OF THE HOLLOW',
        description: 'Defeat all 5 bosses.',
        unlocked: unlockedIds.contains('all_bosses'),
      ),
      Achievement(
        id: 'backstory_unlock',
        title: 'HISTORIAN',
        description: 'Unlock a hero\'s full backstory.',
        unlocked: unlockedIds.contains('backstory_unlock'),
      ),
      Achievement(
        id: 'no_damage_team',
        title: 'UNTOUCHABLE SQUAD',
        description: 'Complete a team level without taking damage.',
        unlocked: unlockedIds.contains('no_damage_team'),
      ),
      Achievement(
        id: 'fully_upgraded',
        title: 'FULLY UPGRADED',
        description: 'Unlock all 3 skill upgrades on any hero.',
        unlocked: unlockedIds.contains('fully_upgraded'),
      ),
      Achievement(
        id: 'daily_completed',
        title: 'DEDICATED AGENT',
        description: 'Complete a daily challenge.',
        unlocked: unlockedIds.contains('daily_completed'),
      ),
    ];
  }
}
