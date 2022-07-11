import 'package:args/args.dart';
import 'package:images_files_checker/src/domain/assets_entries/models/asset_density.dart';
import 'package:images_files_checker/src/domain/common/result.dart';
import 'package:images_files_checker/src/domain/user_options/models/user_options.dart';
import 'package:images_files_checker/src/domain/user_options/repositories/user_options_repository.dart';

class UserOptionsRepositoryImpl implements UserOptionsRepository {
  static const defaultSupportedResolutions = "1.0x,1.5x,2.0x,3.0x,4.0x";
  static const defaultSupportedFiles = "jpeg,webp,png,gif,bmp,wbmp";

  final ArgParser argParser;

  UserOptionsRepositoryImpl(this.argParser);

  factory UserOptionsRepositoryImpl.defaultImplementation() {
    return UserOptionsRepositoryImpl(ArgParser());
  }

  bool optionsRegistered = false;

  void _registerAvailableOptions() {
    if (optionsRegistered) {
      return;
    }
    optionsRegistered = true;
    argParser.addOption(
      "path",
      mandatory: true,
      help: "Asset image path",
    );
    argParser.addOption(
      "resolutions",
      help: "Expected resolutions variantes",
      defaultsTo: defaultSupportedResolutions,
    );
    argParser.addOption(
      "extensions",
      help: "image extensions that will be checked",
      defaultsTo: defaultSupportedFiles,
    );
    argParser.addFlag(
      "fail-test-on-unexpected-dir",
      help:
          "If a image is in a subdir that doesn't fallow the pattern `#.#x`, it will be considered an error",
      defaultsTo: false,
    );
    argParser.addFlag(
      "fail-test-on-decoding-error",
      help: "Images that failed to decode will be reported as an error",
      defaultsTo: false,
    );
    argParser.addOption(
      "ignore",
      help: "files that will be ignored, including its extensions",
      defaultsTo: null,
    );
  }

  @override
  Result<UserOptions> getUserOptions(List<String> arguments) {
    try {
      _registerAvailableOptions();
      final result = argParser.parse(arguments);
      return ResultSuccess(UserOptions(
        imagePath: result["path"],
        expectedDensities: result["resolutions"]
            .toLowerCase()
            .split(",")
            .map((e) => AssetDensity.fromString(e))
            .whereType<AssetDensity>() // filtering not null values
            .toList(growable: false),
        supportedFiles: result["extensions"].toLowerCase().split(","),
        unexpectedSubDirIsAnError: result["fail-test-on-unexpected-dir"],
        decodingFailIsAnError: result["fail-test-on-decoding-error"],
        ignoredFiles: result["ignore"]
                ?.toLowerCase()
                .split(",")
                .toList(growable: false) ??
            [],
      ));
    } catch (e) {
      return ResultError(e.toString());
    }
  }
}
