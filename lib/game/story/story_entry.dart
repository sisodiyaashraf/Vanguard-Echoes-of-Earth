class StoryEntry {
  final String speakerName;
  final String? portraitAssetPath;
  final String text;

  const StoryEntry({
    required this.speakerName,
    this.portraitAssetPath,
    required this.text,
  });
}
