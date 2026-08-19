import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final files = [
    'assets/images/characters/kitsune holographic (superpower).png',
    'assets/images/characters/kitsune holographic (transformation).png',
    'assets/images/characters/Shark — Hydrokinetic Agility(superpower).png',
    'assets/images/characters/Shark — Hydrokinetic Agility(Transformation).png',
  ];

  for (var path in files) {
    final file = File(path);
    if (!file.existsSync()) {
      print('File not found: $path');
      continue;
    }
    final bytes = file.readAsBytesSync();
    final image = img.decodeImage(bytes);
    if (image == null) {
      print('Failed to decode $path');
    } else {
      print('$path: ${image.width}x${image.height}');
    }
  }
}
