import 'package:images_files_checker/src/domain/assets_entries/models/asset_density.dart';
import 'package:images_files_checker/src/domain/assets_entries/models/image_resolution.dart';
import 'package:images_files_checker/src/domain/checkers/models/analyse_result_error.dart';
import 'package:images_files_checker/src/domain/common/pair.dart';

enum ComparisonFailType {
  smaller,
  bigger,
  equal,
}

class ComparisonFail implements AnalyseResultError {
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
