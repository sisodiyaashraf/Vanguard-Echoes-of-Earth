class SkillNode {
  final String id;
  final String name;
  final String description;
  final int cost;
  bool unlocked;

  SkillNode({
    required this.id,
    required this.name,
    required this.description,
    this.cost = 1,
    this.unlocked = false,
  });

  static List<SkillNode> getSkillsForHero(String heroName) {
    switch (heroName.toLowerCase()) {
      case 'dragon':
        return [
          SkillNode(
            id: 'dragon_flame_reach',
            name: 'LAVA SURGE',
            description: 'Flame shockwave size and lifetime increased by 30%.',
          ),
          SkillNode(
            id: 'dragon_faster_cooldown',
            name: 'KINETIC RECOIL',
            description: 'Superpower cooldown reduced by 15%.',
          ),
          SkillNode(
            id: 'dragon_thicker_scales',
            name: 'THICKER SCALES',
            description: 'Max health increased by +10.',
          ),
        ];
      case 't-rex':
        return [
          SkillNode(
            id: 'trex_seismic_size',
            name: 'SEISMIC RESONANCE',
            description: 'Seismic slam area increased by 30%.',
          ),
          SkillNode(
            id: 'trex_unbreakable_guard',
            name: 'TECTONIC SHELL',
            description: 'Max health increased by +15.',
          ),
          SkillNode(
            id: 'trex_rage_energy',
            name: 'PRIMAL FUEL',
            description: 'Max energy increased by +20.',
          ),
        ];
      case 'curator':
        return [
          SkillNode(
            id: 'curator_nanotech_shield',
            name: 'NANOTECH SHIELDING',
            description: 'Max health increased by +10.',
          ),
          SkillNode(
            id: 'curator_temporal_flow',
            name: 'TEMPORAL WARP',
            description: 'Superpower cooldown reduced by 15%.',
          ),
          SkillNode(
            id: 'curator_heavy_wave',
            name: 'DECAY INTENSITY',
            description: 'Temporal wave speed and damage increased by 20%.',
          ),
        ];
      case 'shark':
        return [
          SkillNode(
            id: 'shark_water_blades',
            name: 'RIPTIDE EDGE',
            description: 'Water blade projectile damage increased by 25%.',
          ),
          SkillNode(
            id: 'shark_rapid_agility',
            name: 'HYDRODYNAMIC GLIDE',
            description: 'Superpower cooldown reduced by 15%.',
          ),
          SkillNode(
            id: 'shark_deep_lung',
            name: 'ABYSSAL RESERVES',
            description: 'Max energy increased by +20.',
          ),
        ];
      case 'kitsune':
      default:
        return [
          SkillNode(
            id: 'kitsune_clone_duration',
            name: 'PERSISTENT ILLUSION',
            description: 'Decoy clone duration increased by 30%.',
          ),
          SkillNode(
            id: 'kitsune_trickster_cd',
            name: 'QUICK AMBUSH',
            description: 'Superpower cooldown reduced by 15%.',
          ),
          SkillNode(
            id: 'kitsune_neon_evasion',
            name: 'PHASING AEGIS',
            description: 'Max health increased by +15.',
          ),
        ];
    }
  }
}
