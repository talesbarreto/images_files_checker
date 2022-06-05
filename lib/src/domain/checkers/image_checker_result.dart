import 'package:images_files_checker/src/domain/assets/models/asset_density.dart';
import 'package:images_files_checker/src/domain/common/pair.dart';
import 'package:images_files_checker/src/domain/repositories/image_metadata/image_resolution.dart';

class ImageCheckResult {
  final String imageFileName;
  final List<ImageFilesCheckerResultError> errors;

  const ImageCheckResult({required this.imageFileName, required this.errors});
}

enum ImageFilesCheckerResultErrorType {
  testFail,
  executionWarning,
}

abstract class ImageFilesCheckerResultError {
  ImageFilesCheckerResultErrorType get errorType;
}

class MissingFileError implements ImageFilesCheckerResultError {
  final AssetDensity assetDensity;

  MissingFileError(this.assetDensity);

  @override
  ImageFilesCheckerResultErrorType get errorType => ImageFilesCheckerResultErrorType.testFail;
}

enum ComparisonFailType {
  smaller,
  bigger,
  equal,
}

class ComparisonFail implements ImageFilesCheckerResultError {
  final Pair<AssetDensity, ImageResolution> targetFile;
  final Pair<AssetDensity, ImageResolution> comparedFile;
  final ComparisonFailType comparisonFailType;

  @override
  ImageFilesCheckerResultErrorType get errorType => ImageFilesCheckerResultErrorType.testFail;

  const ComparisonFail({
    required this.targetFile,
    required this.comparedFile,
    required this.comparisonFailType,
  });
}

class DecodeError implements ImageFilesCheckerResultError {
  final String fileName;

  const DecodeError(this.fileName);

  @override
  ImageFilesCheckerResultErrorType get errorType => ImageFilesCheckerResultErrorType.executionWarning;
}
