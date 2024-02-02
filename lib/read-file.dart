import 'dart:io';

// Data is trimmed data.trim() because there might be wierd
// leading/trailing spaces/newlines.
Future<String?> readSysFile(String fileName) async {
  try {
    var file = File(fileName);
    if (await file.exists()) {
      var data = await file.readAsString();
      return data.trim();
    } else {
      // print("No file -> $file");
      return null;
    }
  } catch (e) {
    print('Error reading file: $e');
    return null;
  }
}
