import 'dart:io';

import 'package:images_files_checker/src/domain/assets_entries/models/asset_density.dart';
import 'package:images_files_checker/src/domain/assets_entries/models/asset_entries.dart';
import 'package:images_files_checker/src/domain/checkers/models/image_decode_error.dart';
import 'package:images_files_checker/src/domain/checkers/models/unexpected_sub_dir_error.dart';
import 'package:images_files_checker/src/domain/common/result.dart';
import 'package:images_files_checker/src/domain/assets_entries/repositories/image_metadata_repository.dart';
import 'package:images_files_checker/src/domain/assets_entries/models/image_resolution.dart';
import 'package:images_files_checker/src/domain/checkers/use_cases/is_file_supported.dart';
import 'package:images_files_checker/src/domain/user_options/models/user_options.dart';
import 'package:images_files_checker/src/extensions/file.dart';

class RetrieveAssetEntries {
  final IsFileSupported isFileSupported;
  final ImageMetadataRepository imageMetadataRepository;

  const RetrieveAssetEntries(this.isFileSupported, this.imageMetadataRepository);

  AssetDensity? _getImageDensity(ImageMetadataRepository imageMetadataDataSource, UserOptions userOptions, File file) {
    final imageDensityResult = imageMetadataDataSource.getImagePixelDensity(file, userOptions.imagePath);
    if (imageDensityResult is ResultSuccess) {
      return (imageDensityResult as ResultSuccess).data;
    } else {
      return null;
    }
  }

  Future<List<AssetEntry>> call({
    required UserOptions userOptions,
    required List<File> files,
  }) async {
    final assetEntries = <AssetEntry>[];
    for (final file in files) {
      if (!isFileSupported(userOptions.supportedFiles, file)) {
        continue;
      }

      final AssetDensity? imageDensity = _getImageDensity(imageMetadataRepository, userOptions, file);
      if (imageDensity == null) {
        assetEntries.registerError(file.fileName, UnexpectedSubDirError(file.path));
        continue;
      }
      final resolution = await imageMetadataRepository.getImageResolution(file);
      if (resolution is ResultSuccess<ImageResolution>) {
        assetEntries.addDetectedDensity(file.fileName, imageDensity, resolution.data);
      } else if (resolution is ResultError) {
        assetEntries.registerError(file.fileName, ImageDecodeError(file.fileName, (resolution as ResultError).message));
      }
    }

    return assetEntries;
  }
}
