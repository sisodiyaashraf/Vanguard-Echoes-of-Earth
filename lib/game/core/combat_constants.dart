enum EnemyAnimState { idle, chase, attack, hurt, dead }

class CombatConstants {
  static const double meleeAttackDuration = 0.35;

  // Dragon - Plasma Shockwave
  static const double plasmaCooldown = 1.0;
  static const int plasmaEnergyCost = 25;
  static const double plasmaSpeed = 400.0;
  static const double plasmaLifetime = 1.0;

  // T-Rex - Seismic Slam
  static const double seismicCooldown = 1.5;
  static const int seismicEnergyCost = 30;
  static const double seismicDuration = 0.4;

  // Curator - Temporal Wave
  static const double temporalCooldown = 1.2;
  static const int temporalEnergyCost = 25;
  static const double temporalSpeed = 250.0;
  static const double temporalLifetime = 1.5;

  // Shark - Water Blade Barrage
  static const double waterBladeCooldown = 0.8;
  static const int waterBladeEnergyCost = 20;
  static const double waterBladeSpeed = 450.0;
  static const double waterBladeLifetime = 0.6;

  // Kitsune - Holo Clone Ambush
  static const double holoCloneCooldown = 2.0;
  static const int holoCloneEnergyCost = 35;
  static const double holoCloneDuration = 2.0;

  // Damage Constants
  static const int basicAttackDamage = 15;
  static const int plasmaDamage = 30;
  static const int seismicDamage = 40;
  static const int temporalDamage = 25;
  static const int waterBladeDamage = 20;

  // Enemy Combat Statistics
  static const int enemyMaxHealth = 50;
  static const int enemyContactDamage = 10;
  static const double enemySpeed = 80.0;
  static const double enemyAggroRange = 150.0;
  static const double enemyAttackRange = 40.0;
  static const double enemyContactDamageCooldown = 1.0;
}

