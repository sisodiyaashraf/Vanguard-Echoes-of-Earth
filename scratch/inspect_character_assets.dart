import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final files = [
    'assets/images/characters/Curator (Temporal Nanotech).png',
    'assets/images/characters/Curator -run.png',
    'assets/images/characters/Curator jump and attack.png',
    'assets/images/characters/Hero 2 T-Rex (Seismic Hammer).png',
    'assets/images/characters/T-Rex -run.png',
    'assets/images/characters/T-Rex -run -jump and attack.png',
    'assets/images/characters/Shark (Hydrokinetic Agility).png',
    'assets/images/characters/Shark -run.png',
    'assets/images/characters/Shark -jump and attack.png',
    'assets/images/characters/Kitsune (Holographic).png',
    'assets/images/characters/Kitsune -run.png',
    'assets/images/characters/Kitsune - jump and attack.png',
    'assets/images/characters/VFX (effects, transparent).png'
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
