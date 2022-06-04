import 'dart:io';

import 'package:images_files_checker/src/domain/checkers/image_files_checker.dart';
import 'package:images_files_checker/src/domain/common/result.dart';
import 'package:images_files_checker/src/domain/repositories/image_metadata/models/image_resolution.dart';
import 'package:images_files_checker/src/domain/repositories/user_options/user_options.dart';
import 'package:test/test.dart';

import 'fake_image_metadata_repository.dart';

void main() {
  final defaultSupportedResolutions = ["1.0x", "1.5x", "2.0x"];
  final defaultSupportedFiles = ["png"];
  final defaultUserOptions = UserOptions(
    imagePath: "assets/images",
    expectedResolutions: defaultSupportedResolutions,
    supportedFiles: defaultSupportedFiles,
  );

  test("When `files` is empty, return an empty list ", () async {
    final checker = ImageFilesChecker(
      files: [],
      userOptions: defaultUserOptions,
      imageMetadataDataSource: FakeImageMetadataRepository.defaultAnswer(ImageResolution(height: 0, width: 0)),
    );

    final result = await checker();

    expect(result, []);
  });

  test("When there is one unsupported file, return an empty list ", () async {
    final checker = ImageFilesChecker(
      files: [File("${defaultUserOptions.imagePath}/unsupported.svg")],
      userOptions: defaultUserOptions,
      imageMetadataDataSource: FakeImageMetadataRepository.defaultAnswer(ImageResolution(height: 0, width: 0)),
    );

    final result = await checker();
    expect(result, []);
  });


  test("When there one supported image that has all resolutions files, return a ImageFilesCheckerResult with no errors", () async {
    final files = [
      File("${defaultUserOptions.imagePath}/unsupported.png"),
      File("${defaultUserOptions.imagePath}/1.5x/unsupported.png"),
      File("${defaultUserOptions.imagePath}/2.0x/unsupported.png"),
    ];
    final checker = ImageFilesChecker(
      files: files,
      userOptions: defaultUserOptions,
      imageMetadataDataSource: FakeImageMetadataRepository({
        files[0].path: ResultSuccess(ImageResolution(height: 0, width: 0)),
        files[1].path: ResultSuccess(ImageResolution(height: 10, width: 10)),
        files[2].path: ResultSuccess(ImageResolution(height: 100, width: 100)),
      }),
    );

    final result = await checker();
    expect(result.first.errors.isEmpty, isTrue);
  });

  test("When one resolution file is missing, return an error", () async {
    final files = [
      File("${defaultUserOptions.imagePath}/unsupported.png"),
      File("${defaultUserOptions.imagePath}/1.5x/unsupported.png"),
    ];
    final checker = ImageFilesChecker(
      files: files,
      userOptions: defaultUserOptions,
      imageMetadataDataSource: FakeImageMetadataRepository({
        files[0].path: ResultSuccess(ImageResolution(height: 0, width: 0)),
        files[1].path: ResultSuccess(ImageResolution(height: 10, width: 10)),
      }),
    );

    final result = await checker();
    expect(result.first.errors.length, 1);
  });

  test("When two resolution files are swapped, return an error", () async {
    final files = [
      File("${defaultUserOptions.imagePath}/unsupported.png"),
      File("${defaultUserOptions.imagePath}/1.5x/unsupported.png"),
      File("${defaultUserOptions.imagePath}/2.0x/unsupported.png"),
    ];
    final checker = ImageFilesChecker(
      files: files,
      userOptions: defaultUserOptions,
      imageMetadataDataSource: FakeImageMetadataRepository({
        files[0].path: ResultSuccess(ImageResolution(height: 0, width: 0)),
        files[1].path: ResultSuccess(ImageResolution(height: 100, width: 100)),
        files[2].path: ResultSuccess(ImageResolution(height: 10, width: 10)),
      }),
    );

    final result = await checker();
    expect(result.first.errors.length, 1);
  });

  test("When two resolution files have the same resolution, return an error", () async {
    final files = [
      File("${defaultUserOptions.imagePath}/unsupported.png"),
      File("${defaultUserOptions.imagePath}/1.5x/unsupported.png"),
      File("${defaultUserOptions.imagePath}/2.0x/unsupported.png"),
    ];
    final checker = ImageFilesChecker(
      files: files,
      userOptions: defaultUserOptions,
      imageMetadataDataSource: FakeImageMetadataRepository({
        files[0].path: ResultSuccess(ImageResolution(height: 0, width: 0)),
        files[1].path: ResultSuccess(ImageResolution(height: 100, width: 100)),
        files[2].path: ResultSuccess(ImageResolution(height: 100, width: 100)),
      }),
    );

    final result = await checker();
    expect(result.first.errors.length, 1);
  });
}
