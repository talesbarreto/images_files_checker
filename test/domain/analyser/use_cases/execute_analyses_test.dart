import 'package:images_files_checker/src/domain/analyser/exit_code.dart';
import 'package:images_files_checker/src/domain/analyser/use_cases/execute_analyses.dart';
import 'package:images_files_checker/src/domain/analyser/use_cases/get_error_message.dart';
import 'package:images_files_checker/src/domain/assets_entries/models/asset_density.dart';
import 'package:images_files_checker/src/domain/assets_entries/models/asset_entries.dart';
import 'package:images_files_checker/src/domain/assets_entries/models/image_resolution.dart';
import 'package:images_files_checker/src/domain/checkers/models/image_decode_error.dart';
import 'package:images_files_checker/src/domain/checkers/models/image_resolution_error.dart';
import 'package:images_files_checker/src/domain/checkers/models/missing_file_error.dart';
import 'package:images_files_checker/src/domain/checkers/models/unexpected_sub_dir_error.dart';
import 'package:images_files_checker/src/domain/checkers/use_cases/register_inconsistencies_between_densities.dart';
import 'package:images_files_checker/src/domain/checkers/use_cases/register_missing_asset_files.dart';
import 'package:images_files_checker/src/domain/common/pair.dart';
import 'package:images_files_checker/src/domain/user_options/models/user_options.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'execute_analyses_test.mocks.dart';

@GenerateMocks([], customMocks: [
  MockSpec<RegisterMissingAssetFiles>(returnNullOnMissingStub: true),
  MockSpec<RegisterInconsistenciesBetweenDensities>(returnNullOnMissingStub: true),
  MockSpec<GetErrorMessage>(returnNullOnMissingStub: true),
])
void main() {
  group("When `ExecuteAnalyses()` is invoked", () {
    const userOptions = UserOptions(
      imagePath: "assets/images",
      expectedDensities: [],
      supportedFiles: ["png"],
      decodingFailIsAnError: false,
      unexpectedSubDirIsAnError: false,
      ignoredFiles: [],
    );
    final assets = [AssetEntry(fileName: 'ha.png')];

    test("Register call RegisterMissingAssetFiles checker", () async {
      final registerMissingAssetFiles = MockRegisterMissingAssetFiles();
      final registerInconsistenciesBetweenDensities = MockRegisterInconsistenciesBetweenDensities();
      final getErrorMessage = MockGetErrorMessage();

      final executeAnalyses = ExecuteAnalyses(
        getErrorMessage: getErrorMessage,
        registerMissingAssetFiles: registerMissingAssetFiles,
        registerInconsistenciesBetweenDensities: registerInconsistenciesBetweenDensities,
      );

      await executeAnalyses(userOptions: userOptions, assets: assets, log: (_) {});
      for (final entry in assets) {
        verify(registerMissingAssetFiles.call(userOptions, entry)).called(1);
      }
    });

    test("Register call RegisterInconsistenciesBetweenDensities checker", () async {
      final registerMissingAssetFiles = MockRegisterMissingAssetFiles();
      final registerInconsistenciesBetweenDensities = MockRegisterInconsistenciesBetweenDensities();
      final getErrorMessage = MockGetErrorMessage();

      final executeAnalyses = ExecuteAnalyses(
        getErrorMessage: getErrorMessage,
        registerMissingAssetFiles: registerMissingAssetFiles,
        registerInconsistenciesBetweenDensities: registerInconsistenciesBetweenDensities,
      );

      await executeAnalyses(userOptions: userOptions, assets: assets, log: (_) {});
      for (final entry in assets) {
        verify(registerInconsistenciesBetweenDensities.call(userOptions, entry)).called(1);
      }
    });
  });

  group("When an entry has only one `ImageDecodeError`", () {
    final assets = [AssetEntry(fileName: 'ha.png')];
    final executeAnalyses = ExecuteAnalyses(
      getErrorMessage: MockGetErrorMessage(),
      registerMissingAssetFiles: MockRegisterMissingAssetFiles(),
      registerInconsistenciesBetweenDensities: MockRegisterInconsistenciesBetweenDensities(),
    );
    assets.first.errors.add(ImageDecodeError("", ""));

    test("Return `ExitCode.noErrorsFounds` if `userOptions.decodingFailIsAnError` is false", () async {
      const userOptions = UserOptions(
        imagePath: "assets/images",
        expectedDensities: [],
        supportedFiles: ["png"],
        decodingFailIsAnError: false,
        unexpectedSubDirIsAnError: false,
        ignoredFiles: [],
      );

      final result = await executeAnalyses(userOptions: userOptions, assets: assets, log: (_) {});

      expect(result, ExitCode.noErrorsFounds);
    });
    test("Return `ExitCode.testFail` if `userOptions.decodingFailIsAnError` is true", () async {
      const userOptions = UserOptions(
        imagePath: "assets/images",
        expectedDensities: [],
        supportedFiles: ["png"],
        decodingFailIsAnError: true,
        unexpectedSubDirIsAnError: false,
        ignoredFiles: [],
      );

      final result = await executeAnalyses(userOptions: userOptions, assets: assets, log: (_) {});

      expect(result, ExitCode.testFail);
    });
  });

  group("When an entry has only one `UnexpectedSubDirError`", () {
    final assets = [AssetEntry(fileName: 'ha.png')];
    final executeAnalyses = ExecuteAnalyses(
      getErrorMessage: MockGetErrorMessage(),
      registerMissingAssetFiles: MockRegisterMissingAssetFiles(),
      registerInconsistenciesBetweenDensities: MockRegisterInconsistenciesBetweenDensities(),
    );
    assets.first.errors.add(UnexpectedSubDirError(""));

    test("Return `ExitCode.noErrorsFounds` if `userOptions.decodingFailIsAnError` is false", () async {
      const userOptions = UserOptions(
        imagePath: "assets/images",
        expectedDensities: [],
        supportedFiles: ["png"],
        decodingFailIsAnError: false,
        unexpectedSubDirIsAnError: false,
        ignoredFiles: [],
      );

      final result = await executeAnalyses(userOptions: userOptions, assets: assets, log: (_) {});

      expect(result, ExitCode.noErrorsFounds);
    });
    test("Return `ExitCode.testFail` if `userOptions.decodingFailIsAnError` is true", () async {
      const userOptions = UserOptions(
        imagePath: "assets/images",
        expectedDensities: [],
        supportedFiles: ["png"],
        decodingFailIsAnError: false,
        unexpectedSubDirIsAnError: true,
        ignoredFiles: [],
      );

      final result = await executeAnalyses(userOptions: userOptions, assets: assets, log: (_) {});

      expect(result, ExitCode.testFail);
    });
  });

  group("Returns `ExitCode.testFail` if", () {
    const dummyDensity = AssetDensity(1, 2);
    const dummyResolution = ImageResolution(height: 1, width: 2);

    const userOptions = UserOptions(
      imagePath: "assets/images",
      expectedDensities: [],
      supportedFiles: ["png"],
      decodingFailIsAnError: false,
      unexpectedSubDirIsAnError: false,
      ignoredFiles: [],
    );

    final executeAnalyses = ExecuteAnalyses(
      getErrorMessage: MockGetErrorMessage(),
      registerMissingAssetFiles: MockRegisterMissingAssetFiles(),
      registerInconsistenciesBetweenDensities: MockRegisterInconsistenciesBetweenDensities(),
    );

    test("assets has a ComparisonFail", () async {
      final asset = AssetEntry(fileName: 'ha.png')
        ..errors.add(ComparisonFail(
          comparisonFailType: ComparisonFailType.smaller,
          comparedFile: Pair(dummyDensity, dummyResolution),
          targetFile: Pair(dummyDensity, dummyResolution),
        ));
      final result = await executeAnalyses(userOptions: userOptions, assets: [asset], log: (_) {});
      expect(result, ExitCode.testFail);
    });
    test("assets has a MissingFileError", () async {
      final asset = AssetEntry(fileName: 'ha.png')..errors.add(MissingFileError(dummyDensity));
      final result = await executeAnalyses(userOptions: userOptions, assets: [asset], log: (_) {});
      expect(result, ExitCode.testFail);
    });
  });
}
