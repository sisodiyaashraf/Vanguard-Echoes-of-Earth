import 'package:flame/extensions.dart';
import 'package:vanguard_echoes_of_earth/game/levels/level_config.dart';
import 'package:vanguard_echoes_of_earth/game/core/platform_data.dart';

class BossRushConfig extends LevelConfig {
  BossRushConfig({required String heroId})
      : super(
          id: 'boss_rush',
          displayName: 'BOSS RUSH',
          heroId: heroId,
          backgroundAssetPath: 'backgrounds/cyberpunk_bg.png',
          levelSize: Vector2(2000, 600),
          platforms: const [
            PlatformData(
              position: Offset(0, 450),
              size: Offset(2000, 150),
            ),
          ],
        );
}
