import 'dart:io';

import 'package:images_files_checker/src/domain/assets_entries/models/asset_density.dart';
import 'package:images_files_checker/src/domain/common/result.dart';
import 'package:images_files_checker/src/domain/assets_entries/models/image_resolution.dart';

abstract class ImageMetadataRepository {
  static const defaultDensity = AssetDensity(1, 0);

  Future<Result<ImageResolution>> getImageResolution(File file);

  Result<AssetDensity> getImagePixelDensity(File file, String imagesPath);
}
