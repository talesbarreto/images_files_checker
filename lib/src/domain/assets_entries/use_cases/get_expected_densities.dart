import 'package:images_files_checker/src/domain/assets_entries/models/asset_density.dart';
import 'package:images_files_checker/src/domain/assets_entries/repositories/image_metadata_repository.dart';
import 'package:images_files_checker/src/domain/user_options/models/user_options.dart';

class GetExpectedDensities {
  List<AssetDensity> call(UserOptions userOptions) {
    final resolutions = List.of(userOptions.expectedDensities);
    if (!resolutions.contains(ImageMetadataRepository.defaultDensity)) {
      resolutions.add(ImageMetadataRepository.defaultDensity);
    }
    return resolutions;
  }
}
