import 'package:images_files_checker/src/domain/assets_entries/models/asset_density.dart';
import 'package:images_files_checker/src/domain/common/pair.dart';
import 'package:images_files_checker/src/domain/assets_entries/models/image_resolution.dart';

enum ImageFilesCheckerResultErrorType {
  testFail,
  executionWarning,
}

abstract class AnalyseResultError {
  ImageFilesCheckerResultErrorType get errorType;
}
