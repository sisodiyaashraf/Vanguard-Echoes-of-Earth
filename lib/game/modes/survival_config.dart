import 'package:flame/extensions.dart';
import 'package:vanguard_echoes_of_earth/game/levels/level_config.dart';
import 'package:vanguard_echoes_of_earth/game/core/platform_data.dart';

class SurvivalConfig extends LevelConfig {
  SurvivalConfig()
      : super(
          id: 'survival',
          displayName: 'SURVIVAL MODE',
          heroId: 'team', // Survival mode launches in team squad mode by default!
          backgroundAssetPath: 'backgrounds/cyberpunk_bg.png',
          levelSize: Vector2(2400, 600),
          platforms: const [
            // Bottom Main Floor
            PlatformData(
              position: Offset(0, 480),
              size: Offset(2400, 120),
            ),
            // Multi-level Ledges for tactical play
            PlatformData(
              position: Offset(300, 320),
              size: Offset(400, 30),
            ),
            PlatformData(
              position: Offset(1700, 320),
              size: Offset(400, 30),
            ),
            PlatformData(
              position: Offset(900, 200),
              size: Offset(600, 30),
            ),
          ],
        );
}
