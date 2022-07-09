import 'package:images_files_checker/src/domain/assets_entries/models/asset_density.dart';

class UserOptions {
  final String imagePath;
  final List<AssetDensity> expectedDensities;
  final List<String> supportedFiles;
  final bool unexpectedSubDirIsAnError;
  final bool decodingFailIsAnError;

  const UserOptions({
    required this.imagePath,
    required this.expectedDensities,
    required this.supportedFiles,
    required this.unexpectedSubDirIsAnError,
    required this.decodingFailIsAnError,
  });
}
