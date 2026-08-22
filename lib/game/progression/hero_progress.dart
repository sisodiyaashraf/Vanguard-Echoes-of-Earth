class HeroProgress {
  final String heroId;
  int xp;
  int level;
  int skillPoints;
  List<String> unlockedSkillIds;

  HeroProgress({
    required this.heroId,
    this.xp = 0,
    this.level = 1,
    this.skillPoints = 0,
    List<String>? unlockedSkillIds,
  }) : unlockedSkillIds = unlockedSkillIds ?? [];

  int get xpToNextLevel => 100 * level;

  // Returns true if a level-up occurred
  bool addXp(int amount) {
    if (amount <= 0) return false;
    xp += amount;
    bool leveledUp = false;
    while (xp >= xpToNextLevel) {
      xp -= xpToNextLevel;
      level++;
      skillPoints++;
      leveledUp = true;
    }
    return leveledUp;
  }
}
