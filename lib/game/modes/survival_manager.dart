import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:vanguard_echoes_of_earth/game/vanguard_game.dart';
import 'package:vanguard_echoes_of_earth/game/components/hollow_enemy.dart';
import 'package:vanguard_echoes_of_earth/game/components/hollow_boss.dart';
import 'package:vanguard_echoes_of_earth/game/components/platform.dart';
import 'package:vanguard_echoes_of_earth/game/core/combat_constants.dart';
import 'package:vanguard_echoes_of_earth/game/core/save_manager.dart';
import 'package:vanguard_echoes_of_earth/game/story/story_entry.dart';
import 'package:vanguard_echoes_of_earth/game/modes/survival_config.dart';

class SurvivalManager extends Component with HasGameReference<VanguardGame> {
  final SurvivalConfig config;
  final Random _random = Random();

  int currentWave = 1;
  int enemiesDefeatedThisRun = 0;
  bool isWaitingForNextWave = false;
  double _waveTimer = 0.0;
  bool isGameOver = false;

  SurvivalManager(this.config);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _startWave();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isGameOver) return;

    if (isWaitingForNextWave) {
      _waveTimer += dt;
      if (_waveTimer >= 3.0) {
        isWaitingForNextWave = false;
        _waveTimer = 0.0;
        _startWave();
      }
      return;
    }

    // Check if all enemies in the current wave are defeated
    final activeEnemies = game.world.children.whereType<HollowEnemy>().where((e) => e.health > 0).length;
    if (activeEnemies == 0 && !isWaitingForNextWave) {
      _onWaveCompleted();
    }
  }

  void _startWave() {
    final enemiesCount = 3 + currentWave;
    game.showDialogue([
      StoryEntry(
        speakerName: 'System',
        text: 'WAVE $currentWave BEGINS: SPONSORING $enemiesCount HOLLOW ENEMIES.',
      )
    ]);

    final platforms = game.world.children.whereType<Platform>().toList();
    if (platforms.isEmpty) return;

    for (int i = 0; i < enemiesCount; i++) {
      // Pick a random platform
      final plat = platforms[_random.nextInt(platforms.length)];
      // Random X on platform
      final x = plat.position.x + _random.nextDouble() * (plat.size.x - 60) + 30;
      final y = plat.position.y - 64; // Spawns above platform

      final variant = _getVariantForWave(currentWave);

      if (variant == EnemyVariant.boss) {
        final bossType = ['dragon', 't-rex', 'curator', 'shark', 'kitsune'][_random.nextInt(5)];
        final boss = HollowBoss(
          bossType: bossType,
          position: Vector2(x, y),
        );
        // Reduce boss health for balance as wave mob
        boss.health = 50;
        boss.maxHealth = 50;
        game.world.add(boss);
      } else {
        final enemy = HollowEnemy(
          variant: variant,
          position: Vector2(x, y),
        );
        game.world.add(enemy);
      }
    }
  }

  void _onWaveCompleted() {
    // Breather dialogue and prep next wave
    isWaitingForNextWave = true;
    _waveTimer = 0.0;
    
    // Save current waves survived and enemies defeated metrics to VanguardGame
    game.survivalWavesSurvived = currentWave;
    game.survivalEnemiesDefeated = enemiesDefeatedThisRun;

    currentWave++;
    FlameAudio.play('win.wav', volume: SaveManager.getSfxVolume() * 0.5);
  }

  EnemyVariant _getVariantForWave(int wave) {
    if (wave <= 2) {
      return EnemyVariant.swarm;
    } else if (wave <= 4) {
      return (_random.nextBool()) ? EnemyVariant.swarm : EnemyVariant.scout;
    } else if (wave <= 6) {
      final roll = _random.nextInt(3);
      if (roll == 0) return EnemyVariant.swarm;
      if (roll == 1) return EnemyVariant.scout;
      return EnemyVariant.soldier;
    } else if (wave <= 9) {
      final roll = _random.nextInt(4);
      if (roll == 0) return EnemyVariant.scout;
      if (roll == 1) return EnemyVariant.soldier;
      return EnemyVariant.brute;
    } else {
      // Wave 10+: any variant including boss spawns!
      final roll = _random.nextInt(5);
      return EnemyVariant.values[roll];
    }
  }

  void registerEnemyDefeat() {
    enemiesDefeatedThisRun++;
    game.survivalEnemiesDefeated = enemiesDefeatedThisRun;
  }

  void onDeathGameOver() {
    if (isGameOver) return;
    isGameOver = true;

    // Save survival high scores
    final bestWaves = SaveManager.getSurvivalBestWaves();
    final bestEnemies = SaveManager.getSurvivalBestEnemies();

    if (currentWave - 1 > bestWaves) {
      SaveManager.saveSurvivalBestWaves(currentWave - 1);
    }
    if (enemiesDefeatedThisRun > bestEnemies) {
      SaveManager.saveSurvivalBestEnemies(enemiesDefeatedThisRun);
    }

    game.survivalWavesSurvived = currentWave - 1;
    game.survivalEnemiesDefeated = enemiesDefeatedThisRun;

    // Trigger Game Over
    game.triggerGameOver();
  }
}
