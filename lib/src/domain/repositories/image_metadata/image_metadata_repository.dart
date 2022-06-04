import 'dart:io';

import 'package:images_files_checker/src/domain/common/result.dart';
import 'package:images_files_checker/src/domain/repositories/image_metadata/models/image_resolution.dart';

abstract class ImageMetadataRepository {
  Future<Result<ImageResolution>> getImageResolution(File file);
}
