import 'dart:io';

import 'package:images_files_checker/src/domain/assets/models/asset_density.dart';
import 'package:images_files_checker/src/domain/common/result.dart';
import 'package:images_files_checker/src/domain/repositories/image_metadata/image_metadata_repository.dart';
import 'package:images_files_checker/src/domain/repositories/image_metadata/image_resolution.dart';

class FakeImageMetadataRepositoryAnswer {
  final ImageResolution imageResolution;
  final AssetDensity assetDensity;

  const FakeImageMetadataRepositoryAnswer(this.imageResolution, this.assetDensity);
}

class FakeImageMetadataRepository implements ImageMetadataRepository {
  final Map<String, FakeImageMetadataRepositoryAnswer> answers;

  FakeImageMetadataRepository(this.answers);

  @override
  Future<Result<ImageResolution>> getImageResolution(File file) async {
    final result = answers[file.path];
    if (result == null) {
      throw ResultError('No answer for ${file.path}');
    }
    return ResultSuccess(result.imageResolution);
  }

  @override
  Future<Result<AssetDensity>> getImagePixelDensity(File file, String imagesPath) async {
    final result = answers[file.path];
    if (result == null) {
      throw ResultError('No answer for ${file.path}');
    }
    return ResultSuccess(result.assetDensity);
  }
}
