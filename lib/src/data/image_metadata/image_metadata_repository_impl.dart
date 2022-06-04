import 'dart:io';
import 'package:image/image.dart';
import 'package:images_files_checker/src/domain/common/result.dart';

import 'package:images_files_checker/src/domain/repositories/image_metadata/image_metadata_repository.dart';
import 'package:images_files_checker/src/domain/repositories/image_metadata/models/image_resolution.dart';

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
}
