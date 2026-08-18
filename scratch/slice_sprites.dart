// ignore_for_file: avoid_print

import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  // 1. Idle (4 frames)
  sliceAndProcess(
    sourcePath: 'assets/images/characters/Dragon — Idle animation strip.png',
    destPath: 'assets/images/dragon_idle.png',
    frameCount: 4,
    frameWidth: 375,
    destFrameSize: 128,
  );

  // 2. Run (6 frames)
  sliceAndProcess(
    sourcePath: 'assets/images/characters/Dragon — Run animation strip.png',
    destPath: 'assets/images/dragon_run.png',
    frameCount: 6,
    frameWidth: 250,
    destFrameSize: 128,
  );

  // 3. Jump (2 frames)
  sliceAndProcess(
    sourcePath: 'assets/images/characters/Dragon — Jump  attack strips.png',
    destPath: 'assets/images/dragon_jump.png',
    frameCount: 2,
    frameWidth: 300,
    destFrameSize: 128,
    startColumn: 0,
  );

  // 4. Attack (3 frames)
  sliceAndProcess(
    sourcePath: 'assets/images/characters/Dragon — Jump  attack strips.png',
    destPath: 'assets/images/dragon_attack.png',
    frameCount: 3,
    frameWidth: 300,
    destFrameSize: 128,
    startColumn: 2,
  );
}

void sliceAndProcess({
  required String sourcePath,
  required String destPath,
  required int frameCount,
  required int frameWidth,
  required int destFrameSize,
  int startColumn = 0,
}) {
  final file = File(sourcePath);
  if (!file.existsSync()) {
    print('Error: $sourcePath does not exist');
    return;
  }

  final bytes = file.readAsBytesSync();
  final srcImg = img.decodePng(bytes);
  if (srcImg == null) {
    print('Error: Failed to decode $sourcePath');
    return;
  }

  final height = srcImg.height;
  
  // Create destination image sheet (horizontal strip)
  final destSheet = img.Image(
    width: destFrameSize * frameCount,
    height: destFrameSize,
    numChannels: 4,
  );

  // Clear sheet to transparent
  img.fill(destSheet, color: img.ColorRgba8(0, 0, 0, 0));

  for (int f = 0; f < frameCount; f++) {
    final col = startColumn + f;
    final xStart = col * frameWidth;
    final xEnd = xStart + frameWidth;

    // 1. Find the bounding box of non-background pixels in this cell
    int minX = xEnd;
    int maxX = xStart;
    int minY = height;
    int maxY = 0;

    for (int x = xStart; x < xEnd; x++) {
      for (int y = 0; y < height; y++) {
        final pixel = srcImg.getPixel(x, y);
        if (!isBackground(pixel)) {
          if (x < minX) minX = x;
          if (x > maxX) maxX = x;
          if (y < minY) minY = y;
          if (y > maxY) maxY = y;
        }
      }
    }

    // Check if we found a valid character bounding box
    if (minX >= maxX || minY >= maxY) {
      print('Warning: empty frame at index $f in $sourcePath');
      continue;
    }

    final boxW = maxX - minX + 1;
    final boxH = maxY - minY + 1;

    // 2. Crop character from source image
    final cropped = img.Image(width: boxW, height: boxH, numChannels: 4);
    for (int y = 0; y < boxH; y++) {
      for (int x = 0; x < boxW; x++) {
        final pixel = srcImg.getPixel(minX + x, minY + y);
        if (isBackground(pixel)) {
          cropped.setPixel(x, y, img.ColorRgba8(0, 0, 0, 0));
        } else {
          cropped.setPixel(
            x,
            y,
            img.ColorRgba8(pixel.r.toInt(), pixel.g.toInt(), pixel.b.toInt(), 255),
          );
        }
      }
    }

    // 3. Center and scale character inside destFrameSize x destFrameSize
    // Margin of 16px around the character
    final int maxFit = destFrameSize - 16;
    double scale = 1.0;
    if (boxW > maxFit || boxH > maxFit) {
      if (boxW > boxH) {
        scale = maxFit / boxW;
      } else {
        scale = maxFit / boxH;
      }
    }

    final newW = (boxW * scale).round();
    final newH = (boxH * scale).round();

    final resized = img.copyResize(
      cropped,
      width: newW,
      height: newH,
      interpolation: img.Interpolation.cubic,
    );

    // Place centered in the destination frame
    final targetX = (f * destFrameSize) + (destFrameSize - newW) ~/ 2;
    final targetY = (destFrameSize - newH) ~/ 2;

    for (int y = 0; y < newH; y++) {
      for (int x = 0; x < newW; x++) {
        final pixel = resized.getPixel(x, y);
        destSheet.setPixel(targetX + x, targetY + y, pixel);
      }
    }
  }

  // Save the destination sheet as PNG
  final pngBytes = img.encodePng(destSheet);
  File(destPath).writeAsBytesSync(pngBytes);
  print('Successfully processed and saved: $destPath');
}

bool isBackground(img.Pixel pixel) {
  // If alpha is very low, it's background
  if (pixel.a < 45) return true;
  
  // If it's very close to white background
  final r = pixel.r;
  final g = pixel.g;
  final b = pixel.b;
  if (r > 235 && g > 235 && b > 235) return true;
  
  return false;
}
