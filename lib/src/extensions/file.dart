import 'dart:io';

extension PathSegments on File {
  String get fileName => path.split("/").last;
}
