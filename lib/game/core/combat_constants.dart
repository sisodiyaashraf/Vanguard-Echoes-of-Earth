enum EnemyAnimState { idle, chase, attack, hurt, dead }

enum EnemyVariant { brute, soldier, scout, swarm, boss }

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
  static const double enemyContactDamageCooldown = 1.0;

  static int getEnemyMaxHealth(EnemyVariant variant) {
    switch (variant) {
      case EnemyVariant.boss:
        return 400;
      case EnemyVariant.brute:
        return 90;
      case EnemyVariant.soldier:
        return 50;
      case EnemyVariant.scout:
        return 30;
      case EnemyVariant.swarm:
        return 15;
    }
  }

  static int getEnemyContactDamage(EnemyVariant variant) {
    switch (variant) {
      case EnemyVariant.boss:
        return 25;
      case EnemyVariant.brute:
        return 20;
      case EnemyVariant.soldier:
        return 10;
      case EnemyVariant.scout:
        return 8;
      case EnemyVariant.swarm:
        return 5;
    }
  }

  static double getEnemySpeed(EnemyVariant variant) {
    switch (variant) {
      case EnemyVariant.boss:
        return 50.0;
      case EnemyVariant.brute:
        return 40.0;
      case EnemyVariant.soldier:
        return 80.0;
      case EnemyVariant.scout:
        return 120.0;
      case EnemyVariant.swarm:
        return 100.0;
    }
  }

  static double getEnemyAggroRange(EnemyVariant variant) {
    switch (variant) {
      case EnemyVariant.boss:
        return 200.0;
      case EnemyVariant.brute:
        return 120.0;
      case EnemyVariant.soldier:
        return 150.0;
      case EnemyVariant.scout:
        return 220.0;
      case EnemyVariant.swarm:
        return 180.0;
    }
  }

  static double getEnemyAttackRange(EnemyVariant variant) {
    switch (variant) {
      case EnemyVariant.boss:
        return 55.0;
      case EnemyVariant.brute:
        return 45.0;
      case EnemyVariant.soldier:
        return 40.0;
      case EnemyVariant.scout:
        return 35.0;
      case EnemyVariant.swarm:
        return 30.0;
    }
  }

  // Boss Combat Constants
  static const double bossTelegraphDuration = 0.7;
  static const double bossAttackCooldown = 2.0;

  // Dragon Boss
  static const int bossDragonFireLineDamage = 20;
  static const int bossDragonDashDamage = 25;
  static const double bossDragonDashSpeed = 250.0;

  // T-Rex Boss
  static const int bossTRexSlamDamage = 30;
  static const int bossTRexRockDamage = 20;
  static const double bossTRexRockSpeed = 300.0;

  // Curator Boss
  static const int bossCuratorDecayDamage = 20;
  static const double bossCuratorPhaseDuration = 2.0;

  // Shark Boss
  static const int bossSharkSpreadDamage = 15;
  static const double bossSharkBladeSpeed = 350.0;
  static const int bossSharkLungeDamage = 25;
  static const double bossSharkLungeSpeed = 300.0;

  // Kitsune Boss
  static const int bossKitsuneStrikeDamage = 20;
  static const double bossKitsuneDecoyDuration = 3.0;
}

