class DailyChallenge {
  final String id;
  final String description;
  final int target;
  final String type; // 'defeatEnemies', 'completeLevels', 'defeatBossNoPower'

  const DailyChallenge({
    required this.id,
    required this.description,
    required this.target,
    required this.type,
  });

  static const List<DailyChallenge> pool = [
    DailyChallenge(
      id: 'defeat_20_enemies',
      description: 'Defeat 20 enemies today',
      target: 20,
      type: 'defeatEnemies',
    ),
    DailyChallenge(
      id: 'complete_2_levels',
      description: 'Complete any 2 levels today',
      target: 2,
      type: 'completeLevels',
    ),
    DailyChallenge(
      id: 'defeat_boss_no_power',
      description: 'Defeat a boss without using power today',
      target: 1,
      type: 'defeatBossNoPower',
    ),
  ];

  static DailyChallenge getChallengeById(String id) {
    return pool.firstWhere((c) => c.id == id, orElse: () => pool.first);
  }
}
