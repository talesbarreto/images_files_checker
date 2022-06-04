import 'package:images_files_checker/src/domain/repositories/image_metadata/models/image_resolution.dart';

class ImageFilesCheckerResult {
  final String imageFileName;
  final List<ImageFilesCheckerResultError> errors;

  const ImageFilesCheckerResult({required this.imageFileName, required this.errors});
}

enum ImageFilesCheckerResultErrorType {
  testFail,
  executionWarning,
}

abstract class ImageFilesCheckerResultError {
  ImageFilesCheckerResultErrorType get errorType;
}

class MissingFileError implements ImageFilesCheckerResultError {
  final String resolutionName;

  MissingFileError(this.resolutionName);

  @override
  ImageFilesCheckerResultErrorType get errorType => ImageFilesCheckerResultErrorType.testFail;
}

enum ComparisonFailType {
  smaller,
  bigger,
  equal,
}

class ComparisonFail implements ImageFilesCheckerResultError {
  final ComparisonFailType comparisonFailType;
  final ImageResolution resolution;
  final String resolutionName;
  final String comparedImageFileResolutionName;
  final ImageResolution comparedImageFileResolution;

  @override
  ImageFilesCheckerResultErrorType get errorType => ImageFilesCheckerResultErrorType.testFail;

  const ComparisonFail({
    required this.resolution,
    required this.resolutionName,
    required this.comparisonFailType,
    required this.comparedImageFileResolutionName,
    required this.comparedImageFileResolution,
  });
}

class DecodeError implements ImageFilesCheckerResultError {
  final String fileName;

  const DecodeError(this.fileName);

  @override
  ImageFilesCheckerResultErrorType get errorType => ImageFilesCheckerResultErrorType.executionWarning;
}
