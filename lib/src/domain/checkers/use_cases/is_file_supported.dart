import 'dart:io';

class IsFileSupported {
  bool call(List<String> supportedFiles, File file) {
    final fileExtension = file.path.split(".").last;
    return supportedFiles.contains(fileExtension.toLowerCase());
  }
}
