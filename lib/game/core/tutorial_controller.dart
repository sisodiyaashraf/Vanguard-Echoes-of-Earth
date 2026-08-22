import 'package:flame/components.dart';
import 'package:vanguard_echoes_of_earth/game/vanguard_game.dart';
import 'package:vanguard_echoes_of_earth/game/core/save_manager.dart';
import 'package:vanguard_echoes_of_earth/game/components/hollow_enemy.dart';
import 'package:vanguard_echoes_of_earth/game/core/combat_constants.dart';

enum TutorialStep {
  none,
  move,
  jump,
  attack,
  power,
  swap,
  complete
}

class TutorialController {
  static final TutorialController instance = TutorialController._();
  TutorialController._();

  bool active = false;
  TutorialStep currentStep = TutorialStep.none;
  HollowEnemy? trainingDummy;

  void startTutorial(VanguardGame game) {
    if (game.currentLevelConfig?.heroId == 'team') {
      if (!SaveManager.hasSeenTeamTutorial()) {
        active = true;
        currentStep = TutorialStep.swap;
        game.overlays.add('tutorial');
      }
    } else {
      if (!SaveManager.hasSeenTutorial()) {
        active = true;
        currentStep = TutorialStep.move;
        game.overlays.add('tutorial');
        game.currentDialogueNotifier.value = null;
      }
    }
  }

  void update(VanguardGame game, double dt) {
    if (!active) return;

    final hero = game.activeHero;
    final input = hero.inputState;

    switch (currentStep) {
      case TutorialStep.move:
        if (input.keyboardMoveX != 0 || input.joystickMoveX != 0) {
          currentStep = TutorialStep.jump;
          game.overlays.remove('tutorial');
          game.overlays.add('tutorial');
        }
        break;

      case TutorialStep.jump:
        if (input.jumpPressed) {
          currentStep = TutorialStep.attack;
          // Spawn the training dummy in front of the player
          final dummyPos = Vector2(hero.position.x + 180, hero.position.y);
          trainingDummy = HollowEnemy(
            variant: EnemyVariant.swarm,
            position: dummyPos,
          );
          // Set very low health for easy defeat
          trainingDummy!.health = 5;
          trainingDummy!.maxHealth = 5;
          game.world.add(trainingDummy!);

          game.overlays.remove('tutorial');
          game.overlays.add('tutorial');
        }
        break;

      case TutorialStep.attack:
        if (trainingDummy == null || trainingDummy!.parent == null || trainingDummy!.health <= 0) {
          currentStep = TutorialStep.power;
          hero.stats.regenEnergy(50);
          game.overlays.remove('tutorial');
          game.overlays.add('tutorial');
        }
        break;

      case TutorialStep.power:
        if (input.powerPressed) {
          active = false;
          currentStep = TutorialStep.complete;
          game.overlays.remove('tutorial');
          SaveManager.setHasSeenTutorial(true);

          if (game.currentLevelConfig?.introSequence != null && game.currentLevelConfig!.introSequence!.isNotEmpty) {
            game.showDialogue(game.currentLevelConfig!.introSequence!);
          }
        }
        break;

      case TutorialStep.swap:
        if (game.activeHeroIndex != 0) {
          active = false;
          currentStep = TutorialStep.complete;
          game.overlays.remove('tutorial');
          SaveManager.setHasSeenTeamTutorial(true);
        }
        break;

      default:
        break;
    }
  }

  void skipTutorial(VanguardGame game) {
    active = false;
    currentStep = TutorialStep.none;
    game.overlays.remove('tutorial');
    if (game.currentLevelConfig?.heroId == 'team') {
      SaveManager.setHasSeenTeamTutorial(true);
    } else {
      SaveManager.setHasSeenTutorial(true);
      if (game.currentLevelConfig?.introSequence != null && game.currentLevelConfig!.introSequence!.isNotEmpty) {
        game.showDialogue(game.currentLevelConfig!.introSequence!);
      }
    }
  }
}
