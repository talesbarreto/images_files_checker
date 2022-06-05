import 'dart:io';

import 'package:images_files_checker/src/domain/assets/models/asset_density.dart';
import 'package:images_files_checker/src/domain/checkers/get_image_checker_results.dart';
import 'package:images_files_checker/src/domain/repositories/image_metadata/image_resolution.dart';
import 'package:images_files_checker/src/domain/repositories/user_options/user_options.dart';
import 'package:test/test.dart';

import 'fake_image_metadata_repository.dart';

void main() {
  const defaultSupportedResolutions = [AssetDensity(1, 0), AssetDensity(1, 5), AssetDensity(2, 0)];
  final defaultSupportedFiles = ["png"];
  final defaultUserOptions = UserOptions(
    imagePath: "assets/images",
    expectedDensities: defaultSupportedResolutions,
    supportedFiles: defaultSupportedFiles,
  );

  test("When `files` is empty, return an empty list ", () async {
    final checker = GetImageCheckerResults();

    final result = await checker(
      files: [],
      userOptions: defaultUserOptions,
      imageMetadataDataSource: FakeImageMetadataRepository({}),
    );

    expect(result, []);
  });

  test("When there is one unsupported file, return an empty list ", () async {
    final checker = GetImageCheckerResults();

    final result = await checker(
      files: [File("${defaultUserOptions.imagePath}/unsupported.svg")],
      userOptions: defaultUserOptions,
      imageMetadataDataSource: FakeImageMetadataRepository({}),
    );
    expect(result, []);
  });

  test("When there one supported image that has all resolutions files, return a ImageFilesCheckerResult with no errors", () async {
    final files = [
      File("${defaultUserOptions.imagePath}/unsupported.png"),
      File("${defaultUserOptions.imagePath}/1.5x/unsupported.png"),
      File("${defaultUserOptions.imagePath}/2.0x/unsupported.png"),
    ];
    final checker = GetImageCheckerResults();

    final result = await checker(
      files: files,
      userOptions: defaultUserOptions,
      imageMetadataDataSource: FakeImageMetadataRepository({
        files[0].path: FakeImageMetadataRepositoryAnswer(ImageResolution(height: 0, width: 0), AssetDensity(1, 0)),
        files[1].path: FakeImageMetadataRepositoryAnswer(ImageResolution(height: 10, width: 10), AssetDensity(1, 5)),
        files[2].path: FakeImageMetadataRepositoryAnswer(ImageResolution(height: 100, width: 100), AssetDensity(2, 0)),
      }),
    );
    expect(result.first.errors.isEmpty, isTrue);
  });

  test("When one resolution file is missing, return an error", () async {
    final files = [
      File("${defaultUserOptions.imagePath}/unsupported.png"),
      File("${defaultUserOptions.imagePath}/1.5x/unsupported.png"),
    ];
    final checker = GetImageCheckerResults();

    final result = await checker(
      files: files,
      userOptions: defaultUserOptions,
      imageMetadataDataSource: FakeImageMetadataRepository({
        files[0].path: FakeImageMetadataRepositoryAnswer(ImageResolution(height: 0, width: 0), AssetDensity(1, 0)),
        files[1].path: FakeImageMetadataRepositoryAnswer(ImageResolution(height: 10, width: 10), AssetDensity(1, 5)),
      }),
    );
    expect(result.first.errors.length, 1);
  });

  test("When two resolution files are swapped, return an error", () async {
    final files = [
      File("${defaultUserOptions.imagePath}/unsupported.png"),
      File("${defaultUserOptions.imagePath}/1.5x/unsupported.png"),
      File("${defaultUserOptions.imagePath}/2.0x/unsupported.png"),
    ];
    final checker = GetImageCheckerResults();

    final result = await checker(
      files: files,
      userOptions: defaultUserOptions,
      imageMetadataDataSource: FakeImageMetadataRepository({
        files[0].path: FakeImageMetadataRepositoryAnswer(ImageResolution(height: 0, width: 0), AssetDensity(1, 0)),
        files[1].path: FakeImageMetadataRepositoryAnswer(ImageResolution(height: 100, width: 100), AssetDensity(1, 5)),
        files[2].path: FakeImageMetadataRepositoryAnswer(ImageResolution(height: 10, width: 10), AssetDensity(2, 0)),
      }),
    );
    expect(result.first.errors.length, 1);
  });

  test("When two resolution files have the same resolution, return an error", () async {
    final files = [
      File("${defaultUserOptions.imagePath}/unsupported.png"),
      File("${defaultUserOptions.imagePath}/1.5x/unsupported.png"),
      File("${defaultUserOptions.imagePath}/2.0x/unsupported.png"),
    ];
    final checker = GetImageCheckerResults();

    final result = await checker(
      files: files,
      userOptions: defaultUserOptions,
      imageMetadataDataSource: FakeImageMetadataRepository({
        files[0].path: FakeImageMetadataRepositoryAnswer(ImageResolution(height: 0, width: 0), AssetDensity(1, 0)),
        files[1].path: FakeImageMetadataRepositoryAnswer(ImageResolution(height: 100, width: 100), AssetDensity(1, 5)),
        files[2].path: FakeImageMetadataRepositoryAnswer(ImageResolution(height: 100, width: 100), AssetDensity(1, 5)),
      }),
    );
    expect(result.first.errors.length, 1);
  });
}
