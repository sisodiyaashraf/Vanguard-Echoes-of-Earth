class Level {
  final int id;
  final String name;
  final String subtitle;
  final String theme;
  final String backgroundAsset;
  final String heroRequirement;
  final bool isLocked;

  const Level({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.theme,
    required this.backgroundAsset,
    required this.heroRequirement,
    this.isLocked = false,
  });
}
