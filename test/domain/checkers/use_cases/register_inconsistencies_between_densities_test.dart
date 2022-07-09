import 'package:images_files_checker/src/domain/assets_entries/models/asset_density.dart';
import 'package:images_files_checker/src/domain/assets_entries/models/asset_entries.dart';
import 'package:images_files_checker/src/domain/assets_entries/models/image_resolution.dart';
import 'package:images_files_checker/src/domain/assets_entries/use_cases/get_expected_densities.dart';
import 'package:images_files_checker/src/domain/checkers/models/image_resolution_error.dart';
import 'package:images_files_checker/src/domain/checkers/use_cases/register_inconsistencies_between_densities.dart';
import 'package:images_files_checker/src/domain/user_options/models/user_options.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'register_inconsistencies_between_densities_test.mocks.dart';

@GenerateMocks([GetExpectedDensities])
void main() {
  const densities = [AssetDensity(1, 0), AssetDensity(1, 5), AssetDensity(2, 0)];
  final getExpectedDensities = MockGetExpectedDensities();
  when(getExpectedDensities.call(any)).thenReturn(densities);

  const defaultUserOptions = UserOptions(
    imagePath: "assets/images",
    expectedDensities: [AssetDensity(1, 0), AssetDensity(1, 5), AssetDensity(2, 0)],
    supportedFiles: ["png"],
    decodingFailIsAnError: false,
    unexpectedSubDirIsAnError: false,
  );

  test("Do not register errors if all densities files seams correct", () {
    final checker = RegisterInconsistenciesBetweenDensities(getExpectedDensities);
    final entry = AssetEntry(fileName: "unsupported.png");
    entry.detectedResolutions.addAll({
      AssetDensity(1, 0): ImageResolution(height: 1, width: 2),
      AssetDensity(1, 5): ImageResolution(height: 3, width: 4),
      AssetDensity(2, 0): ImageResolution(height: 5, width: 6),
    });

    checker(defaultUserOptions, entry);

    expect(entry.hasErrors, isFalse);
  });

  test("When two resolution files are swapped, return an error", () {
    final checker = RegisterInconsistenciesBetweenDensities(getExpectedDensities);
    final entry = AssetEntry(fileName: "unsupported.png");
    entry.detectedResolutions.addAll({
      AssetDensity(1, 0): ImageResolution(height: 1, width: 2),
      AssetDensity(1, 5): ImageResolution(height: 7, width: 8),
      AssetDensity(2, 0): ImageResolution(height: 5, width: 6),
    });

    checker(defaultUserOptions, entry);

    expect(entry.errors.first, isA<ComparisonFail>());
    final error = entry.errors.first as ComparisonFail;
    expect(error.targetFile.first, equals(AssetDensity(2, 0)));
    expect(error.comparisonFailType, ComparisonFailType.smaller);
    expect(error.comparedFile.first, equals(AssetDensity(1, 5)));
  });

  test("When two resolution files are equal, return an error", () {
    final checker = RegisterInconsistenciesBetweenDensities(getExpectedDensities);
    final entry = AssetEntry(fileName: "unsupported.png");
    entry.detectedResolutions.addAll({
      AssetDensity(1, 0): ImageResolution(height: 1, width: 2),
      AssetDensity(1, 5): ImageResolution(height: 5, width: 6),
      AssetDensity(2, 0): ImageResolution(height: 5, width: 6),
    });

    checker(defaultUserOptions, entry);

    expect(entry.errors.first, isA<ComparisonFail>());
    final error = entry.errors.first as ComparisonFail;
    expect(error.targetFile.first, equals(AssetDensity(2, 0)));
    expect(error.comparisonFailType, ComparisonFailType.equal);
    expect(error.comparedFile.first, equals(AssetDensity(1, 5)));
  });
}
