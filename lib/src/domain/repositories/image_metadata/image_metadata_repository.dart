import 'dart:io';

import 'package:images_files_checker/src/domain/assets/models/asset_density.dart';
import 'package:images_files_checker/src/domain/common/result.dart';
import 'package:images_files_checker/src/domain/repositories/image_metadata/image_resolution.dart';

abstract class ImageMetadataRepository {
  static const defaultResolution = AssetDensity(1, 0);

  Future<Result<ImageResolution>> getImageResolution(File file);

  Future<Result<AssetDensity>> getImagePixelDensity(File file, String imagesPath);
}
