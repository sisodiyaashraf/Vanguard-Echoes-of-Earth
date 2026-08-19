import 'story_entry.dart';

class HeroBackstory {
  final String heroName;
  final List<StoryEntry> unlockedEntries;
  final List<StoryEntry> lockedEntries;

  HeroBackstory({
    required this.heroName,
    List<StoryEntry>? unlockedEntries,
    required List<StoryEntry> lockedEntries,
  })  : unlockedEntries = unlockedEntries ?? [],
        lockedEntries = List.from(lockedEntries);

  StoryEntry? unlockNext() {
    if (lockedEntries.isNotEmpty) {
      final entry = lockedEntries.removeAt(0);
      unlockedEntries.add(entry);
      return entry;
    }
    return null;
  }
}
