import 'package:images_files_checker/src/domain/assets_entries/models/asset_density.dart';
import 'package:images_files_checker/src/domain/checkers/models/analyse_result_error.dart';

/// This error means that a image file for that density was expected but doesn't exists
class MissingFileError implements AnalyseResultError {
  final AssetDensity assetDensity;

  const MissingFileError(this.assetDensity);
}
