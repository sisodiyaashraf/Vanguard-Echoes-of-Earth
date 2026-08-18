// ignore_for_file: avoid_print

import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final file = File(
    'assets/images/characters/Dragon — Jump  attack strips.png',
  );
  if (!file.existsSync()) return;

  final image = img.decodePng(file.readAsBytesSync());
  if (image == null) return;

  final width = image.width;
  final height = image.height;

  // Track row occupancy
  final occupied = List<bool>.filled(height, false);
  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      final pixel = image.getPixel(x, y);
      // If pixel is not transparent and not white background
      if (pixel.a > 50 && !(pixel.r > 240 && pixel.g > 240 && pixel.b > 240)) {
        occupied[y] = true;
        break;
      }
    }
  }

  // Find occupied vertical intervals
  final intervals = <List<int>>[];
  bool inInterval = false;
  int start = 0;
  for (int y = 0; y < height; y++) {
    if (occupied[y]) {
      if (!inInterval) {
        start = y;
        inInterval = true;
      }
    } else {
      if (inInterval) {
        intervals.add([start, y - 1]);
        inInterval = false;
      }
    }
  }
  if (inInterval) {
    intervals.add([start, height - 1]);
  }

  print('Jump/Attack strips rows:');
  for (int i = 0; i < intervals.length; i++) {
    final interval = intervals[i];
    final h = interval[1] - interval[0] + 1;
    print('  Row $i: y from ${interval[0]} to ${interval[1]} (height: $h)');
  }
}
