import 'dart:io';

import 'package:images_files_checker/src/domain/analyser/exit_code.dart';
import 'package:images_files_checker/src/domain/assets_entries/repositories/image_files_repository.dart';
import 'package:images_files_checker/src/domain/assets_entries/repositories/image_metadata_repository.dart';
import 'package:images_files_checker/src/domain/assets_entries/use_cases/retrieve_asset_entries.dart';
import 'package:images_files_checker/src/domain/checkers/models/analyse_result_error.dart';
import 'package:images_files_checker/src/domain/checkers/use_cases/register_inconsistencies_between_densities.dart';
import 'package:images_files_checker/src/domain/checkers/use_cases/register_missing_asset_files.dart';
import 'package:images_files_checker/src/domain/common/result.dart';
import 'package:images_files_checker/src/domain/user_options/models/user_options.dart';
import 'package:images_files_checker/src/domain/analyser/use_cases/get_error_message.dart';

class ExecuteAnalyses {
  final ImageFilesRepository imageFilesRepository;
  final ImageMetadataRepository imageMetadataRepository;
  final RetrieveAssetEntries retrieveAssetEntries;
  final RegisterMissingAssetFiles registerMissingAssetFiles;
  final RegisterInconsistenciesBetweenDensities registerInconsistenciesBetweenDensities;
  final GetErrorMessage getErrorMessage;

  const ExecuteAnalyses({
    required this.imageFilesRepository,
    required this.imageMetadataRepository,
    required this.retrieveAssetEntries,
    required this.registerMissingAssetFiles,
    required this.getErrorMessage,
    required this.registerInconsistenciesBetweenDensities,
  });

  Future<int> call({required UserOptions userOptions, required void Function(Object? object) log}) async {
    final files = await imageFilesRepository.getImageFiles(userOptions.imagePath);
    if (files is! ResultSuccess<List<File>>) {
      files as ResultError<List<File>>;
      log(files.message);
      return ExitCode.error;
    }

    final assets = await retrieveAssetEntries(userOptions: userOptions, files: files.data);

    registerMissingAssetFiles(userOptions, assets);
    for (final asset in assets) {
      registerInconsistenciesBetweenDensities(userOptions, asset);
    }

    bool hasErrors = false;
    for (final entry in assets) {
      final errorMessage = getErrorMessage(entry);
      if (errorMessage != null) {
        log(errorMessage);
      }
      for (final error in entry.errors) {
        if (error.errorType == ImageFilesCheckerResultErrorType.testFail) {
          hasErrors = true;
        }
      }
    }

    if (hasErrors) {
      log("\t - Test has failed");
      return ExitCode.testFail;
    } else {
      log("\t - No errors found");
      return ExitCode.noErrorsFounds;
    }
  }
}
