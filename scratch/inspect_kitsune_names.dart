import 'dart:io';

void main() {
  final dir = Directory('assets/images/characters');
  for (var entry in dir.listSync()) {
    final name = entry.uri.pathSegments.last;
    if (name.contains('Kitsune')) {
      print('Name: "$name" -> length: ${name.length}, runes: ${name.runes.toList()}');
    }
  }
}
