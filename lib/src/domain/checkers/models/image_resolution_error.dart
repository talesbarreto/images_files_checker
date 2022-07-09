import 'package:images_files_checker/src/domain/assets_entries/models/asset_density.dart';
import 'package:images_files_checker/src/domain/assets_entries/models/image_resolution.dart';
import 'package:images_files_checker/src/domain/checkers/models/analyse_result_error.dart';
import 'package:images_files_checker/src/domain/common/pair.dart';

enum ComparisonFailType {
  smaller,
  bigger,
  equal,
}

/// This error means that two images have inconsistent resolutions between them.
/// Ex: `2.0x/image_1.png` is smaller than `1.5x/image_2.png`
class ComparisonFail implements AnalyseResultError {
  final Pair<AssetDensity, ImageResolution> targetFile;
  final Pair<AssetDensity, ImageResolution> comparedFile;
  final ComparisonFailType comparisonFailType;

  const ComparisonFail({
    required this.targetFile,
    required this.comparedFile,
    required this.comparisonFailType,
  });
}
