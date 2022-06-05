import 'package:images_files_checker/src/domain/assets/models/asset_density.dart';

class UserOptions {
  final String imagePath;
  final List<AssetDensity> expectedDensities;
  final List<String> supportedFiles;

  const UserOptions({
    required this.imagePath,
    required this.expectedDensities,
    required this.supportedFiles,
  });
}
