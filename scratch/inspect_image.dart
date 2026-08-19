import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final bytes = File('assets/images/characters/UI elements (icons, not animated).png').readAsBytesSync();
  final image = img.decodePng(bytes);
  if (image == null) {
    print('Failed to decode image');
    return;
  }
  print('Image dimensions: ${image.width}x${image.height}');
  
  // Let's find vertical and horizontal bounds of non-empty pixels
  // We'll treat white/transparent as empty.
  // The image background seems to be white in the preview, or transparent. Let's check.
  var isWhiteBg = true;
  for (int y = 0; y < 10 && y < image.height; y++) {
    for (int x = 0; x < 10 && x < image.width; x++) {
      final pixel = image.getPixel(x, y);
      final r = pixel.r;
      final g = pixel.g;
      final b = pixel.b;
      final a = pixel.a;
      if (a > 10 && !(r > 240 && g > 240 && b > 240)) {
        isWhiteBg = false;
      }
    }
  }
  print('Is background white/transparent? $isWhiteBg');
}
