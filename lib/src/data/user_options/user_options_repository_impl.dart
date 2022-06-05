import 'package:args/args.dart';
import 'package:images_files_checker/src/domain/assets/models/asset_density.dart';
import 'package:images_files_checker/src/domain/common/result.dart';
import 'package:images_files_checker/src/domain/repositories/user_options/user_options.dart';
import 'package:images_files_checker/src/domain/repositories/user_options/user_options_repository.dart';

class UserOptionsRepositoryImpl implements UserOptionsRepository {
  static const defaultSupportedResolutions = "1.0x,1.5x,2.0x,3.0x,4.0x";
  static const defaultSupportedFiles = "jpeg,webp,png,gif,bmp,wbmp";

  final ArgParser argParser;

  UserOptionsRepositoryImpl(this.argParser);

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
      help: "Expeted resolutions variantes",
      defaultsTo: defaultSupportedResolutions,
    );
    argParser.addOption(
      "supported-formats",
      help: "Supported image formats extensions",
      defaultsTo: defaultSupportedFiles,
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
            .map((e) => AssetDensity.fromString(e)) // returns a list of AssetDensity?
            .whereType<AssetDensity>() // filtering not null values
            .toList(growable: false),
        supportedFiles: result["supported-formats"].toLowerCase().split(","),
      ));
    } catch (e) {
      return ResultError(e.toString());
    }
  }
}
