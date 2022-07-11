import 'package:images_files_checker/src/domain/analyser/exit_code.dart';
import 'package:images_files_checker/src/domain/analyser/use_cases/get_error_message.dart';
import 'package:images_files_checker/src/domain/assets_entries/models/asset_entries.dart';
import 'package:images_files_checker/src/domain/checkers/models/image_decode_error.dart';
import 'package:images_files_checker/src/domain/checkers/models/unexpected_sub_dir_error.dart';
import 'package:images_files_checker/src/domain/checkers/use_cases/register_inconsistencies_between_densities.dart';
import 'package:images_files_checker/src/domain/checkers/use_cases/register_missing_asset_files.dart';
import 'package:images_files_checker/src/domain/user_options/models/user_options.dart';

class ExecuteAnalyses {
  final RegisterMissingAssetFiles registerMissingAssetFiles;
  final RegisterInconsistenciesBetweenDensities
      registerInconsistenciesBetweenDensities;
  final GetErrorMessage getErrorMessage;

  const ExecuteAnalyses({
    required this.registerMissingAssetFiles,
    required this.registerInconsistenciesBetweenDensities,
    required this.getErrorMessage,
  });

  /// [assets] list of assets to check
  /// [log] receives output messages from analyses
  Future<int> call({
    required UserOptions userOptions,
    required List<AssetEntry> assets,
    required void Function(Object? object) log,
  }) async {
    for (final asset in assets) {
      registerMissingAssetFiles(userOptions, asset);
      registerInconsistenciesBetweenDensities(userOptions, asset);
    }

    bool hasErrors = false;
    for (final entry in assets) {
      final errorMessage = getErrorMessage(entry);
      if (errorMessage != null) {
        log(errorMessage);
      }
      for (final error in entry.errors) {
        if (error is ImageDecodeError) {
          if (userOptions.decodingFailIsAnError) {
            hasErrors = true;
          }
          continue;
        }
        if (error is UnexpectedSubDirError) {
          if (userOptions.unexpectedSubDirIsAnError) {
            hasErrors = true;
          }
          continue;
        }
        hasErrors = true;
      }
    }

    if (hasErrors) {
      log("\n -> Errors were found in the assets");
      return ExitCode.testFail;
    } else {
      log("\n -> Image files are ok");
      return ExitCode.noErrorsFounds;
    }
  }
}
