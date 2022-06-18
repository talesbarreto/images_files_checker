import 'package:images_files_checker/src/domain/assets_entries/use_cases/get_expected_densities.dart';
import 'package:images_files_checker/src/domain/assets_entries/models/asset_entries.dart';
import 'package:images_files_checker/src/domain/checkers/models/missing_file_error.dart';
import 'package:images_files_checker/src/domain/user_options/models/user_options.dart';

class RegisterMissingAssetFiles {
  final GetExpectedDensities getExpectedDensities;

  const RegisterMissingAssetFiles(this.getExpectedDensities);

  void call(UserOptions userOptions, List<AssetEntry> assetEntries) {
    final expectedDensities = getExpectedDensities(userOptions);
    for (final entry in assetEntries) {
      for (final expectedDensity in expectedDensities) {
        final resolution = entry.detectedResolutions[expectedDensity];
        if (resolution == null) {
          entry.errors.add(MissingFileError(expectedDensity));
        }
      }
    }
  }
}
