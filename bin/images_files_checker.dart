import 'dart:io';
import 'dart:math';

import 'package:images_files_checker/src/data/assets_entries/image_files_repository_impl.dart';
import 'package:images_files_checker/src/data/assets_entries/image_metadata_repository_impl.dart';
import 'package:images_files_checker/src/data/user_options/user_options_repository_impl.dart';
import 'package:images_files_checker/src/domain/analyser/exit_code.dart';
import 'package:images_files_checker/src/domain/analyser/use_cases/execute_analyses.dart';
import 'package:images_files_checker/src/domain/analyser/use_cases/get_error_message.dart';
import 'package:images_files_checker/src/domain/assets_entries/repositories/image_files_repository.dart';
import 'package:images_files_checker/src/domain/assets_entries/repositories/image_metadata_repository.dart';
import 'package:images_files_checker/src/domain/assets_entries/use_cases/get_expected_densities.dart';
import 'package:images_files_checker/src/domain/assets_entries/use_cases/retrieve_asset_entries.dart';
import 'package:images_files_checker/src/domain/checkers/use_cases/is_file_supported.dart';
import 'package:images_files_checker/src/domain/checkers/use_cases/register_inconsistencies_between_densities.dart';
import 'package:images_files_checker/src/domain/checkers/use_cases/register_missing_asset_files.dart';
import 'package:images_files_checker/src/domain/common/result.dart';
import 'package:images_files_checker/src/domain/user_options/models/user_options.dart';
import 'package:images_files_checker/src/domain/user_options/repositories/user_options_repository.dart';

ExecuteAnalyses _getExecuteAnalyses() {
  final imageMetadataRepository = ImageMetadataRepositoryImpl.defaultImplementation();
  final imageFilesRepository = ImageFilesRepositoryImpl();
  final getErrorMessage = GetErrorMessage();
  final isFileSupported = IsFileSupported();
  final retrieveAssetEntries = RetrieveAssetEntries(isFileSupported, imageMetadataRepository);
  final getExpectedDensities = GetExpectedDensities();
  final registerMissingAssetFiles = RegisterMissingAssetFiles(getExpectedDensities);
  final registerInconsistenciesBetweenDensities = RegisterInconsistenciesBetweenDensities(getExpectedDensities);

  return ExecuteAnalyses(
    imageFilesRepository: imageFilesRepository,
    imageMetadataRepository: imageMetadataRepository,
    retrieveAssetEntries: retrieveAssetEntries,
    registerMissingAssetFiles: registerMissingAssetFiles,
    getErrorMessage: getErrorMessage,
    registerInconsistenciesBetweenDensities: registerInconsistenciesBetweenDensities,
  );
}

Future<void> main(List<String> arguments) async {
  final UserOptionsRepository argsRepository = UserOptionsRepositoryImpl.defaultImplementation();
  final executeAnalyses = _getExecuteAnalyses();

  final userOptions = argsRepository.getUserOptions(arguments);

  if (userOptions is ResultSuccess<UserOptions>) {
    int exitCode = await executeAnalyses(userOptions: userOptions.data, log: print);
    exit(exitCode);
  } else if (userOptions is ResultError<UserOptions>) {
    print("Error: ${userOptions.message}");
    exit(ExitCode.error);
  }
}
