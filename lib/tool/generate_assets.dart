import 'dart:io';

void main() {
  final assetsDir = Directory('assets');
  
  if (!assetsDir.existsSync()) {
    print('Assets folder not found: ${assetsDir.path}');
    return;
  }
  
  // Find all image files recursively
  final imageExtensions = ['.png', '.jpg', '.jpeg', '.gif', '.webp', '.bmp'];
  final images = <String>[];
  
  void scanDirectory(Directory dir) {
    try {
      for (var entity in dir.listSync(recursive: false)) {
        if (entity is File) {
          final path = entity.path.replaceAll('\\', '/');
          if (imageExtensions.any((ext) => path.toLowerCase().endsWith(ext))) {
            images.add(path);
          }
        } else if (entity is Directory) {
          scanDirectory(entity);
        }
      }
    } catch (e) {
      print('Error scanning ${dir.path}: $e');
    }
  }
  
  scanDirectory(assetsDir);
  
  // Sort for consistent output
  images.sort();
  
  final output = '''
// GENERATED CODE - DO NOT MODIFY BY HAND
// Generated on: ${DateTime.now()}
// Total images: ${images.length}

class GeneratedAssets {
  static const List<String> allImages = [
${images.map((path) => "    '$path',").join('\n')}
  ];
}
''';

  // Create directory if it doesn't exist
  final outputFile = File('lib/generated/assets.dart');
  outputFile.parent.createSync(recursive: true);
  
  outputFile.writeAsStringSync(output);
  print('✓ Generated ${images.length} asset paths');
  print('✓ Saved to: ${outputFile.path}');
  print('\nFound images in:');
  
  // Show summary by folder
  final folders = <String, int>{};
  for (var img in images) {
    final folder = img.substring(0, img.lastIndexOf('/'));
    folders[folder] = (folders[folder] ?? 0) + 1;
  }
  folders.forEach((folder, count) {
    print('  $folder: $count images');
  });
}