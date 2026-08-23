import 'package:flame/extensions.dart';
import 'package:vanguard_echoes_of_earth/game/levels/level_config.dart';
import 'package:vanguard_echoes_of_earth/game/core/platform_data.dart';

class BossRushConfig extends LevelConfig {
  BossRushConfig({required super.heroId})
      : super(
          id: 'boss_rush',
          displayName: 'BOSS RUSH',
          backgroundAssetPath: 'backgrounds/urban_tech.png',
          levelSize: Vector2(2000, 600),
          platforms: [
            PlatformData(
              position: Vector2(0, 450),
              size: Vector2(2000, 150),
            ),
          ],
        );
}
