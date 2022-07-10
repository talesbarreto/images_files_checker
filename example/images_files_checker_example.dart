import 'dart:io';

/// This package is intended to be used on CLI. Ex:
/// flutter pub run images_files_checker --path assets/images --unexpected-dir-is-an-error

void main() async {
  final result = await Process.run("dart", [
    "bin/images_files_checker.dart",
    "--path",
    "./example/images",
    "--resolutions",
    " 1.0x,1.5x",
  ]);
  print(result.stdout);
}
