import 'dart:io';
import 'package:image/image.dart';
import 'package:images_files_checker/extensions/string.dart';
import 'package:images_files_checker/src/domain/assets/models/asset_density.dart';
import 'package:images_files_checker/src/domain/common/result.dart';

import 'package:images_files_checker/src/domain/repositories/image_metadata/image_metadata_repository.dart';
import 'package:images_files_checker/src/domain/repositories/image_metadata/image_resolution.dart';

class ImageMetadataRepositoryImpl implements ImageMetadataRepository {
  const ImageMetadataRepositoryImpl();

  @override
  Future<Result<ImageResolution>> getImageResolution(File file) async {
    final image = decodeImage(await file.readAsBytes());

    if (image == null) {
      return ResultError('Could not decode file ${file.path}');
    }
    return ResultSuccess(ImageResolution(height: image.height, width: image.width));
  }

  @override
  Future<Result<AssetDensity>> getImagePixelDensity(File file, String imagesPath) async {
    final pathSegments = file.path.removePrefix(imagesPath).removePrefix("/").split("/");
    Result<AssetDensity> result;
    try {
      result = ResultSuccess(pathSegments.length > 1 ? AssetDensity.fromString(pathSegments.first) : ImageMetadataRepository.defaultResolution);
    } catch (e) {
      result = ResultError(e.toString());
    }
    return result;
  }
}
