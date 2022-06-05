import 'dart:io';

import 'package:images_files_checker/src/domain/common/result.dart';

abstract class ImageFilesRepository {
  Future<Result<List<File>>> getImageFiles(String path);
}
