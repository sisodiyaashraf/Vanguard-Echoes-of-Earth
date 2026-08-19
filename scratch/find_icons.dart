import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final bytes = File('assets/images/characters/UI elements (icons, not animated).png').readAsBytesSync();
  final image = img.decodePng(bytes);
  if (image == null) return;

  final w = image.width;
  final h = image.height;

  // Let's find column ranges where there are colored/non-white pixels
  final List<int> colNonBgCount = List.filled(w, 0);
  for (int x = 0; x < w; x++) {
    for (int y = 0; y < h; y++) {
      final p = image.getPixel(x, y);
      if (isNotBg(p)) {
        colNonBgCount[x]++;
      }
    }
  }

  // Let's find row ranges where there are colored/non-white pixels
  final List<int> rowNonBgCount = List.filled(h, 0);
  for (int y = 0; y < h; y++) {
    for (int x = 0; x < w; x++) {
      final p = image.getPixel(x, y);
      if (isNotBg(p)) {
        rowNonBgCount[y]++;
      }
    }
  }

  // Group columns
  final List<Map<String, int>> columns = [];
  bool inCol = false;
  int startX = 0;
  for (int x = 0; x < w; x++) {
    if (colNonBgCount[x] > 0 && !inCol) {
      startX = x;
      inCol = true;
    } else if (colNonBgCount[x] == 0 && inCol) {
      columns.add({'start': startX, 'end': x - 1});
      inCol = false;
    }
  }
  if (inCol) {
    columns.add({'start': startX, 'end': w - 1});
  }

  // Group rows
  final List<Map<String, int>> rows = [];
  bool inRow = false;
  int startY = 0;
  for (int y = 0; y < h; y++) {
    if (rowNonBgCount[y] > 0 && !inRow) {
      startY = y;
      inRow = true;
    } else if (rowNonBgCount[y] == 0 && inRow) {
      rows.add({'start': startY, 'end': y - 1});
      inRow = false;
    }
  }
  if (inRow) {
    rows.add({'start': startY, 'end': h - 1});
  }

  print('Detected row bands:');
  for (var r in rows) {
    print('  Row: ${r['start']} to ${r['end']} (height: ${(r['end']! - r['start']! + 1)})');
  }

  print('Detected columns within bands:');
  for (var r in rows) {
    print('For row band ${r['start']}..${r['end']}:');
    // For each column group, find its exact vertical sub-range
    for (var col in columns) {
      // Find min/max Y for this specific column area
      int minY = 999999;
      int maxY = -1;
      int count = 0;
      for (int x = col['start']!; x <= col['end']!; x++) {
        for (int y = r['start']!; y <= r['end']!; y++) {
          final p = image.getPixel(x, y);
          if (isNotBg(p)) {
            if (y < minY) minY = y;
            if (y > maxY) maxY = y;
            count++;
          }
        }
      }
      if (count > 0) {
        print('  Col: ${col['start']}..${col['end']} (width: ${col['end']! - col['start']! + 1}) -> Y: $minY..$maxY (height: ${maxY - minY + 1})');
      }
    }
  }
}

bool isNotBg(img.Pixel p) {
  final r = p.r;
  final g = p.g;
  final b = p.b;
  final a = p.a;
  if (a < 10) return false;
  // If it's pure white or very close to white background:
  if (r > 250 && g > 250 && b > 250) return false;
  return true;
}
