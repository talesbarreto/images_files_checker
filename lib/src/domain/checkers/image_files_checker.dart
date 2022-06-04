import 'dart:io';

import 'package:images_files_checker/extensions/string.dart';
import 'package:images_files_checker/src/domain/common/result.dart';
import 'package:images_files_checker/src/domain/repositories/image_metadata/models/image_resolution.dart';

import '../repositories/image_metadata/image_metadata_repository.dart';
import '../repositories/user_options/user_options.dart';
import 'models/image_files_checker_result.dart';

const _defaultResolution = "1.0x";

class _ImageEntry {
  final String name;
  final Map<String, ImageResolution?> detectedResolutions = {}; // Key is the resolution name, ex: '1.5x'

  _ImageEntry({required this.name});
}

class ImageFilesChecker {
  final List<File> files;
  final UserOptions userOptions;
  final ImageMetadataRepository imageMetadataDataSource;

  const ImageFilesChecker({
    required this.files,
    required this.userOptions,
    required this.imageMetadataDataSource,
  });

  List<String> _getExpectedResolution() {
    final resolutions = List.of(userOptions.expectedResolutions);
    if (!resolutions.contains(_defaultResolution)) {
      resolutions.add(_defaultResolution);
    }
    resolutions.sort();
    return resolutions;
  }

  ImageFilesCheckerResult _analyseImageFile(_ImageEntry imageEntry) {
    final List<ImageFilesCheckerResultError> errors = [];
    final resolutionNames = _getExpectedResolution();

    for (final resolutionName in resolutionNames) {
      final resolution = imageEntry.detectedResolutions[resolutionName];
      if (resolution != null) {
        if (resolutionName != _defaultResolution) {
          final previousResolutionName = resolutionNames[resolutionNames.indexOf(resolutionName) - 1];
          final previousResolution = imageEntry.detectedResolutions[previousResolutionName];

          if (previousResolution != null) {
            if (previousResolution > resolution) {
              errors.add(
                ComparisonFail(
                  resolution: resolution,
                  resolutionName: resolutionName,
                  comparisonFailType: ComparisonFailType.smaller,
                  comparedImageFileResolutionName: previousResolutionName,
                  comparedImageFileResolution: previousResolution,
                ),
              );
            } else if (previousResolution == resolution) {
              errors.add(
                ComparisonFail(
                  resolution: resolution,
                  resolutionName: resolutionName,
                  comparisonFailType: ComparisonFailType.equal,
                  comparedImageFileResolutionName: previousResolutionName,
                  comparedImageFileResolution: previousResolution,
                ),
              );
            }
          }
        }
      } else {
        errors.add(MissingFileError(resolutionName));
      }
    }
    return ImageFilesCheckerResult(imageFileName: imageEntry.name, errors: errors);
  }

  Future<List<ImageFilesCheckerResult>> call() async {
    final errors = <ImageFilesCheckerResult>[];
    final readImages = <_ImageEntry>[];

    for (final file in files) {
      final pathSegments = file.path.removePrefix(userOptions.imagePath).removePrefix("/").split("/");
      final fileName = pathSegments.last;
      final fileExtension = fileName.split(".").last;
      if (userOptions.supportedFiles.contains(fileExtension.toLowerCase())) {
        final resolutionName = pathSegments.length > 1 ? pathSegments.first : _defaultResolution;

        final image = readImages.firstWhere((e) => e.name == fileName, orElse: () {
          final entry = _ImageEntry(
            name: fileName,
          );
          readImages.add(entry);
          return entry;
        });
        final resolution = await imageMetadataDataSource.getImageResolution(file);
        if (resolution is ResultSuccess<ImageResolution>) {
          image.detectedResolutions[resolutionName] = resolution.data;
        } else if (resolution is ResultError) {
          errors.add(ImageFilesCheckerResult(imageFileName: fileName, errors: [DecodeError(fileName)]));
        }
      }
    }
    for (final readImage in readImages) {
      final error = _analyseImageFile(readImage);
      errors.add(error);
    }
    return errors;
  }
}
