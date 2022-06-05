import 'dart:io';

import 'package:images_files_checker/extensions/string.dart';
import 'package:images_files_checker/src/domain/assets/models/asset_density.dart';
import 'package:images_files_checker/src/domain/common/pair.dart';
import 'package:images_files_checker/src/domain/common/result.dart';
import 'package:images_files_checker/src/domain/repositories/image_metadata/image_resolution.dart';

import '../repositories/image_metadata/image_metadata_repository.dart';
import '../repositories/user_options/user_options.dart';
import 'image_checker_result.dart';

class GetImageCheckerResults {
  const GetImageCheckerResults();

  List<AssetDensity> _getExpectedDensities(UserOptions userOptions) {
    final resolutions = List.of(userOptions.expectedDensities);
    if (!resolutions.contains(ImageMetadataRepository.defaultResolution)) {
      resolutions.add(ImageMetadataRepository.defaultResolution);
    }
    resolutions.sort();
    return resolutions;
  }

  ImageCheckResult _analyseImageFile(UserOptions userOptions, _ImageEntry imageEntry) {
    final List<ImageFilesCheckerResultError> errors = [];
    final expectedDensities = _getExpectedDensities(userOptions);

    for (final density in expectedDensities) {
      final resolution = imageEntry.detectedResolutions[density];
      if (resolution != null) {
        if (density != ImageMetadataRepository.defaultResolution) {
          final previousDensity = expectedDensities[expectedDensities.indexOf(density) - 1];
          final previousResolution = imageEntry.detectedResolutions[previousDensity];

          if (previousResolution != null) {
            if (previousResolution > resolution) {
              errors.add(
                ComparisonFail(
                  comparisonFailType: ComparisonFailType.smaller,
                  targetFile: Pair(density, resolution),
                  comparedFile: Pair(previousDensity, previousResolution),
                ),
              );
            } else if (previousResolution == resolution) {
              errors.add(
                ComparisonFail(
                  comparisonFailType: ComparisonFailType.equal,
                  targetFile: Pair(density, resolution),
                  comparedFile: Pair(previousDensity, previousResolution),
                ),
              );
            }
          }
        }
      } else {
        errors.add(MissingFileError(density));
      }
    }
    return ImageCheckResult(imageFileName: imageEntry.name, errors: errors);
  }

  Future<AssetDensity?> _getImageDensity(ImageMetadataRepository imageMetadataDataSource, UserOptions userOptions, File file) async {
    final imageDensityResult = await imageMetadataDataSource.getImagePixelDensity(file, userOptions.imagePath);
    if (imageDensityResult is ResultSuccess) {
      return (imageDensityResult as ResultSuccess).data;
    } else {
      return null;
    }
  }

  String _getFileName(UserOptions userOptions, File file) {
    final pathSegments = file.path.removePrefix(userOptions.imagePath).removePrefix("/").split("/");
    return pathSegments.last;
  }

  bool _isFileSupported(UserOptions userOptions, File file) {
    final fileExtension = _getFileName(userOptions, file).split(".").last;
    return userOptions.supportedFiles.contains(fileExtension.toLowerCase());
  }

  Future<List<ImageCheckResult>> call({
    required List<File> files,
    required UserOptions userOptions,
    required ImageMetadataRepository imageMetadataDataSource,
  }) async {
    final errors = <ImageCheckResult>[];
    final readImages = <_ImageEntry>[];

    for (final file in files) {
      if (_isFileSupported(userOptions, file)) {
        final AssetDensity? imageDensity = await _getImageDensity(imageMetadataDataSource, userOptions, file);
        if (imageDensity == null) {
          continue;
        }

        final fileName = _getFileName(userOptions, file);

        final image = readImages.firstWhere((e) => e.name == fileName, orElse: () {
          final entry = _ImageEntry(
            name: fileName,
          );
          readImages.add(entry);
          return entry;
        });
        final resolution = await imageMetadataDataSource.getImageResolution(file);
        if (resolution is ResultSuccess<ImageResolution>) {
          image.detectedResolutions[imageDensity] = resolution.data;
        } else if (resolution is ResultError) {
          errors.add(ImageCheckResult(imageFileName: fileName, errors: [DecodeError(fileName)]));
        }
      }
    }
    for (final readImage in readImages) {
      final error = _analyseImageFile(userOptions, readImage);
      errors.add(error);
    }
    return errors;
  }
}

class _ImageEntry {
  final String name;
  final Map<AssetDensity, ImageResolution?> detectedResolutions = {};

  _ImageEntry({required this.name});
}
