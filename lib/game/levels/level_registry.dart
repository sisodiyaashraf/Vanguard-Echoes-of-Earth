import 'level_config.dart';
import 'dragon_levels.dart';
import 'trex_levels.dart';
import 'curator_levels.dart';
import 'shark_levels.dart';
import 'kitsune_levels.dart';
import 'team_levels.dart';

class LevelRegistry {
  static final List<LevelConfig> levels = [
    ...DragonLevels.levels,
    ...TRexLevels.levels,
    ...CuratorLevels.levels,
    ...SharkLevels.levels,
    ...KitsuneLevels.levels,
    ...TeamLevels.levels,
  ];
}
