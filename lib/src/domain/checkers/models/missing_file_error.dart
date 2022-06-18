import 'package:images_files_checker/src/domain/assets_entries/models/asset_density.dart';
import 'package:images_files_checker/src/domain/checkers/models/analyse_result_error.dart';

class MissingFileError implements AnalyseResultError {
  final AssetDensity assetDensity;

  MissingFileError(this.assetDensity);

  @override
  ImageFilesCheckerResultErrorType get errorType => ImageFilesCheckerResultErrorType.testFail;
}
