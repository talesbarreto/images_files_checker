import 'package:images_files_checker/src/domain/assets_entries/use_cases/get_expected_densities.dart';
import 'package:images_files_checker/src/domain/assets_entries/models/asset_entries.dart';
import 'package:images_files_checker/src/domain/checkers/models/image_resolution_error.dart';
import 'package:images_files_checker/src/domain/common/pair.dart';
import 'package:images_files_checker/src/domain/user_options/models/user_options.dart';

class RegisterInconsistenciesBetweenDensities {
  final GetExpectedDensities getExpectedDensities;

  const RegisterInconsistenciesBetweenDensities(this.getExpectedDensities);

  void call(UserOptions userOptions, AssetEntry entry) {
    final expectedDensities = List.of(getExpectedDensities(userOptions));
    expectedDensities.sort();

    for (int i = 1; i < expectedDensities.length; i++) {
      final resolution = entry.detectedResolutions[expectedDensities[i]];
      final previousAssetResolution =
          entry.detectedResolutions[expectedDensities[i - 1]];

      if (resolution == null || previousAssetResolution == null) {
        continue;
      }

      if (resolution < previousAssetResolution) {
        entry.errors.add(
          ComparisonFail(
            comparisonFailType: ComparisonFailType.smaller,
            targetFile: Pair(expectedDensities[i], resolution),
            comparedFile:
                Pair(expectedDensities[i - 1], previousAssetResolution),
          ),
        );
      } else if (resolution == previousAssetResolution) {
        entry.errors.add(
          ComparisonFail(
            comparisonFailType: ComparisonFailType.equal,
            targetFile: Pair(expectedDensities[i], resolution),
            comparedFile:
                Pair(expectedDensities[i - 1], previousAssetResolution),
          ),
        );
      }
    }
  }
}
