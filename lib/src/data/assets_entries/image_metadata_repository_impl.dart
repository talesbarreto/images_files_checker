import 'dart:io';
import 'package:image/image.dart' as image_lib;
import 'package:images_files_checker/src/extensions/string.dart';
import 'package:images_files_checker/src/domain/assets_entries/models/asset_density.dart';
import 'package:images_files_checker/src/domain/common/result.dart';

import 'package:images_files_checker/src/domain/assets_entries/repositories/image_metadata_repository.dart';
import 'package:images_files_checker/src/domain/assets_entries/models/image_resolution.dart';

class ImageMetadataRepositoryImpl implements ImageMetadataRepository {
  final Future<image_lib.Image?> Function(File file) decodeImage;

  const ImageMetadataRepositoryImpl(this.decodeImage);

  factory ImageMetadataRepositoryImpl.defaultImplementation() {
    return ImageMetadataRepositoryImpl((file) async {
      final bytes = await file.readAsBytes();
      return image_lib.decodeImage(bytes);
    });
  }

  @override
  Future<Result<ImageResolution>> getImageResolution(File file) async {
    final image = await decodeImage(file);
    if (image == null) {
      return ResultError('Could not decode image file ${file.path}');
    }
    return ResultSuccess(ImageResolution(height: image.height, width: image.width));
  }

  @override
  Result<AssetDensity> getImagePixelDensity(File file, String imagesPath) {
    final pathSegments = file.path.removePrefix(imagesPath).removePrefix("/").split("/");
    try {
      if (pathSegments.length > 1) {
        return ResultSuccess(AssetDensity.fromString(pathSegments.first));
      } else {
        return ResultSuccess(ImageMetadataRepository.defaultDensity);
      }
    } catch (e) {
      return ResultError(e.toString());
    }
  }
}
