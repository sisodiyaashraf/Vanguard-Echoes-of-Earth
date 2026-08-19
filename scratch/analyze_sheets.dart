import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final files = [
    'assets/images/characters/Curator -run.png',
    'assets/images/characters/T-Rex -run.png',
    'assets/images/characters/Shark -run.png',
    'assets/images/characters/Kitsune - run.png',
  ];

  for (var path in files) {
    print('Analyzing $path...');
    final file = File(path);
    if (!file.existsSync()) {
      print('File not found: $path');
      continue;
    }
    final bytes = file.readAsBytesSync();
    final image = img.decodeImage(bytes);
    if (image == null) continue;
    
    final w = image.width;
    final h = image.height;
    
    // Find rows and cols
    final List<int> colCount = List.filled(w, 0);
    final List<int> rowCount = List.filled(h, 0);
    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        final p = image.getPixel(x, y);
        if (isNotBg(p)) {
          colCount[x]++;
          rowCount[y]++;
        }
      }
    }
    
    // Rows list
    final List<Map<String, int>> rows = [];
    bool inRow = false;
    int startY = 0;
    for (int y = 0; y < h; y++) {
      if (rowCount[y] > 0 && !inRow) {
        startY = y;
        inRow = true;
      } else if (rowCount[y] == 0 && inRow) {
        rows.add({'start': startY, 'end': y - 1});
        inRow = false;
      }
    }
    if (inRow) rows.add({'start': startY, 'end': h - 1});
    
    // Cols list
    final List<Map<String, int>> cols = [];
    bool inCol = false;
    int startX = 0;
    for (int x = 0; x < w; x++) {
      if (colCount[x] > 0 && !inCol) {
        startX = x;
        inCol = true;
      } else if (colCount[x] == 0 && inCol) {
        cols.add({'start': startX, 'end': x - 1});
        inCol = false;
      }
    }
    if (inCol) cols.add({'start': startX, 'end': w - 1});
    
    print('  Dimensions: ${w}x${h}');
    print('  Rows found: ${rows.length}');
    for (var r in rows) {
      print('    Row: ${r['start']}..${r['end']} (height: ${r['end']! - r['start']! + 1})');
    }
    print('  Cols found: ${cols.length}');
    for (var c in cols.take(6)) {
      print('    Col: ${c['start']}..${c['end']} (width: ${c['end']! - c['start']! + 1})');
    }
    if (cols.length > 6) {
      print('    ... and ${cols.length - 6} more columns');
    }
  }
}

bool isNotBg(img.Pixel p) {
  final a = p.a;
  if (a < 10) return false;
  final r = p.r;
  final g = p.g;
  final b = p.b;
  if (r > 250 && g > 250 && b > 250) return false;
  return true;
}
