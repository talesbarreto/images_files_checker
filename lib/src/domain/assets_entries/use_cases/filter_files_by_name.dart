import 'dart:io';

import 'package:images_files_checker/src/extensions/file.dart';

class FilterFilesByName {
  List<File> call(List<File> files, List<String> ignoredFiles) {
    return files.where((file) {
      return !ignoredFiles.contains(file.fileName);
    }).toList(growable: false);
  }
}
