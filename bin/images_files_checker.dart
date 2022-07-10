import 'dart:io';

import 'package:images_files_checker/src/data/assets_entries/image_files_repository_impl.dart';
import 'package:images_files_checker/src/data/assets_entries/image_metadata_repository_impl.dart';
import 'package:images_files_checker/src/data/user_options/user_options_repository_impl.dart';
import 'package:images_files_checker/src/domain/analyser/exit_code.dart';
import 'package:images_files_checker/src/domain/analyser/use_cases/execute_analyses.dart';
import 'package:images_files_checker/src/domain/analyser/use_cases/get_error_message.dart';
import 'package:images_files_checker/src/domain/assets_entries/models/asset_entries.dart';
import 'package:images_files_checker/src/domain/assets_entries/use_cases/get_expected_densities.dart';
import 'package:images_files_checker/src/domain/assets_entries/use_cases/retrieve_asset_entries.dart';
import 'package:images_files_checker/src/domain/checkers/use_cases/is_file_supported.dart';
import 'package:images_files_checker/src/domain/checkers/use_cases/register_inconsistencies_between_densities.dart';
import 'package:images_files_checker/src/domain/checkers/use_cases/register_missing_asset_files.dart';
import 'package:images_files_checker/src/domain/common/result.dart';
import 'package:images_files_checker/src/domain/user_options/models/user_options.dart';
import 'package:images_files_checker/src/domain/user_options/repositories/user_options_repository.dart';

ExecuteAnalyses _getExecuteAnalyses() {
  final getErrorMessage = GetErrorMessage();
  final getExpectedDensities = GetExpectedDensities();
  final registerMissingAssetFiles =
      RegisterMissingAssetFiles(getExpectedDensities);
  final registerInconsistenciesBetweenDensities =
      RegisterInconsistenciesBetweenDensities(getExpectedDensities);

  return ExecuteAnalyses(
    registerMissingAssetFiles: registerMissingAssetFiles,
    getErrorMessage: getErrorMessage,
    registerInconsistenciesBetweenDensities:
        registerInconsistenciesBetweenDensities,
  );
}

UserOptions _getOrFailUserOptions(List<String> arguments) {
  final UserOptionsRepository argsRepository =
      UserOptionsRepositoryImpl.defaultImplementation();
  final userOptions = argsRepository.getUserOptions(arguments);
  if (userOptions is ResultSuccess<UserOptions>) {
    return userOptions.data;
  } else {
    userOptions as ResultError<UserOptions>;
    print("Error: ${userOptions.message}");
    exit(ExitCode.error);
  }
}

Future<List<AssetEntry>> _getOrFailAssetEntries(UserOptions userOptions) async {
  final files =
      await ImageFilesRepositoryImpl().getImageFiles(userOptions.imagePath);
  if (files is! ResultSuccess<List<File>>) {
    files as ResultError<List<File>>;
    print(files.message);
    exit(ExitCode.error);
  }
  final retrieveAssetEntries = RetrieveAssetEntries(
      IsFileSupported(), ImageMetadataRepositoryImpl.defaultImplementation());
  return retrieveAssetEntries(userOptions: userOptions, files: files.data);
}

Future<void> main(List<String> arguments) async {
  final executeAnalyses = _getExecuteAnalyses();

  final userOptions = _getOrFailUserOptions(arguments);

  final assets = await _getOrFailAssetEntries(userOptions);

  int exitCode = await executeAnalyses(
      userOptions: userOptions, assets: assets, log: print);
  exit(exitCode);
}
