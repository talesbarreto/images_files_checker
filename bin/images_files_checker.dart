import 'dart:io';

import 'package:args/args.dart';
import 'package:images_files_checker/src/data/image_files/image_files_repository_impl.dart';
import 'package:images_files_checker/src/data/image_metadata/image_metadata_repository_impl.dart';
import 'package:images_files_checker/src/data/user_options/user_options_repository_impl.dart';
import 'package:images_files_checker/src/domain/checkers/get_image_checker_results.dart';
import 'package:images_files_checker/src/domain/checkers/image_checker_result.dart';
import 'package:images_files_checker/src/domain/common/result.dart';
import 'package:images_files_checker/src/domain/repositories/image_files/image_files_repository.dart';
import 'package:images_files_checker/src/domain/repositories/image_metadata/image_metadata_repository.dart';
import 'package:images_files_checker/src/domain/repositories/user_options/user_options.dart';
import 'package:images_files_checker/src/domain/repositories/user_options/user_options_repository.dart';
import 'package:images_files_checker/src/presentation/get_error_message.dart';

import 'exit_code.dart';

Future<void> main(List<String> arguments) async {
  final UserOptionsRepository argsRepository = UserOptionsRepositoryImpl(ArgParser());
  final ImageMetadataRepository imageMetadataDataSource = ImageMetadataRepositoryImpl();
  final ImageFilesRepository imageFilesRepository = ImageFilesRepositoryImpl();

  final getImageCheckerResults = GetImageCheckerResults();
  final getErrorMessage = GetErrorMessage();

  final userOptions = argsRepository.getUserOptions(arguments);
  if (userOptions is ResultSuccess<UserOptions>) {
    final Result<List<File>> files = await imageFilesRepository.getImageFiles(userOptions.data.imagePath);

    if (files is! ResultSuccess<List<File>>) {
      files as ResultError<List<File>>;
      print(files.message);
      exit(ExitCode.error);
    }

    final imageResult = await getImageCheckerResults(
      files: files.data,
      userOptions: userOptions.data,
      imageMetadataDataSource: imageMetadataDataSource,
    );

    final errorOutput = StringBuffer();

    bool hasErrors = false;
    for (final report in imageResult) {
      final errorMessage = getErrorMessage(report);
      if (errorMessage != null) {
        errorOutput.write(errorMessage);
      }
      for (final error in report.errors) {
        if (error.errorType == ImageFilesCheckerResultErrorType.testFail) {
          hasErrors = true;
        }
      }
    }
    if (hasErrors) {
      print(errorOutput);
      exit(ExitCode.testFail);
    } else {
      print("${imageResult.length} images checked and no errors were found");
      exit(ExitCode.noErrorFounds);
    }
  } else if (userOptions is ResultError<UserOptions>) {
    print("Error: ${userOptions.message}");
    exit(ExitCode.error);
  }
}
