import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:vanguard_echoes_of_earth/game/vanguard_game.dart';
import 'package:vanguard_echoes_of_earth/game/components/hollow_boss.dart';
import 'package:vanguard_echoes_of_earth/game/core/save_manager.dart';
import 'package:vanguard_echoes_of_earth/game/core/game_state.dart';
import 'package:vanguard_echoes_of_earth/game/story/story_entry.dart';
import 'package:vanguard_echoes_of_earth/game/modes/boss_rush_config.dart';

class BossRushManager extends Component with HasGameReference<VanguardGame> {
  final BossRushConfig config;

  final List<String> bossSequence = ['dragon', 't-rex', 'curator', 'shark', 'kitsune'];
  int currentBossIndex = 0;
  double elapsedTime = 0.0;
  bool isRunComplete = false;
  bool isWaitingForNext = false;
  double _waitTimer = 0.0;

  HollowBoss? _activeBoss;

  BossRushManager(this.config);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Spawn first boss
    _spawnBoss(bossSequence[0]);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isRunComplete) return;

    if (game.gameState == GameState.playing) {
      elapsedTime += dt;
      game.bossRushElapsedTime = elapsedTime;
    }

    if (isWaitingForNext) {
      _waitTimer += dt;
      if (_waitTimer >= 3.0) {
        isWaitingForNext = false;
        _waitTimer = 0.0;
        _spawnBoss(bossSequence[currentBossIndex]);
      }
      return;
    }

    // Check if current boss is dead
    if (_activeBoss != null && _activeBoss!.health <= 0 && !isWaitingForNext) {
      _activeBoss = null;
      _onBossDefeated();
    }
  }

  void _spawnBoss(String bossType) async {
    // Spawns boss at right side of the arena
    final boss = HollowBoss(
      bossType: bossType,
      position: Vector2(1500, 350), // Floor is at Y=450
    );
    _activeBoss = boss;
    await game.world.add(boss);

    game.showDialogue([
      StoryEntry(
        speakerName: 'System',
        text: 'WARNING: ${bossType.toUpperCase()} BOSS HAS ENTERED THE ARENA!',
      )
    ]);
  }

  void _onBossDefeated() {
    // Heal player active hero partially (+50%)
    final hero = game.activeHero;
    final healHp = (hero.stats.maxHealth * 0.5).toInt();
    final healEnergy = (hero.stats.maxEnergy * 0.5).toInt();

    hero.stats.heal(healHp);
    hero.stats.regenEnergy(healEnergy);

    currentBossIndex++;

    if (currentBossIndex >= bossSequence.length) {
      _completeRun();
    } else {
      isWaitingForNext = true;
      _waitTimer = 0.0;

      game.showDialogue([
        StoryEntry(
          speakerName: 'System',
          text: 'BOSS DEFEATED! Breather initiated: +50% HP & Energy restored. Preparing next encounter...',
        )
      ]);
    }
  }

  void _completeRun() {
    isRunComplete = true;

    // Save completion time per hero
    final heroName = game.activeHero.heroName;
    final bestTime = SaveManager.getBossRushBestTime(heroName);
    if (bestTime == 0.0 || elapsedTime < bestTime) {
      SaveManager.saveBossRushBestTime(heroName, elapsedTime);
    }

    // Unlock achievement
    game.unlockAchievement('boss_rush_champion');

    // Trigger victory complete
    game.completeLevelFromManager();
  }
}
