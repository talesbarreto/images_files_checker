import 'package:images_files_checker/src/domain/assets_entries/models/asset_density.dart';
import 'package:images_files_checker/src/domain/assets_entries/models/asset_entries.dart';
import 'package:images_files_checker/src/domain/assets_entries/models/image_resolution.dart';
import 'package:images_files_checker/src/domain/assets_entries/use_cases/get_expected_densities.dart';
import 'package:images_files_checker/src/domain/checkers/models/missing_file_error.dart';
import 'package:images_files_checker/src/domain/checkers/use_cases/register_missing_asset_files.dart';
import 'package:images_files_checker/src/domain/user_options/models/user_options.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'register_missing_asset_files_test.mocks.dart';

@GenerateMocks([], customMocks: [
  MockSpec<GetExpectedDensities>(onMissingStub: OnMissingStub.returnDefault),
])
void main() {
  const densities = [AssetDensity(1, 5), AssetDensity(2, 0)];

  test("When all files are detected, do not register any errors", () {
    final mockGetExpectedDensities = MockGetExpectedDensities();
    when(mockGetExpectedDensities.call(any)).thenReturn(densities);

    final entry = AssetEntry(fileName: "file.png");
    entry.detectedResolutions.addAll({
      densities[0]: ImageResolution(height: 1, width: 2),
      densities[1]: ImageResolution(height: 3, width: 4),
    });

    const userOptions = UserOptions(
      imagePath: "assets/images",
      expectedDensities: densities,
      supportedFiles: ["png"],
      decodingFailIsAnError: false,
      unexpectedSubDirIsAnError: false,
      ignoredFiles: [],
    );

    final useCase = RegisterMissingAssetFiles(mockGetExpectedDensities);

    useCase(userOptions, entry);

    expect(entry.hasErrors, false);
  });

  test("When all density 1.5 is missing,register error", () {
    final mockGetExpectedDensities = MockGetExpectedDensities();
    when(mockGetExpectedDensities.call(any)).thenReturn(densities);

    final entry = AssetEntry(fileName: "file.png");
    entry.detectedResolutions.addAll({
      densities[1]: ImageResolution(height: 3, width: 4),
    });

    const userOptions = UserOptions(
      imagePath: "assets/images",
      expectedDensities: densities,
      supportedFiles: ["png"],
      decodingFailIsAnError: false,
      unexpectedSubDirIsAnError: false,
      ignoredFiles: [],
    );

    final useCase = RegisterMissingAssetFiles(mockGetExpectedDensities);

    useCase(userOptions, entry);

    expect(entry.errors.length, equals(1));
    expect(entry.errors.first, isA<MissingFileError>());
  });
}
