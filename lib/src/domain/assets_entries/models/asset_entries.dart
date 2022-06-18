import 'package:images_files_checker/src/domain/assets_entries/models/asset_density.dart';
import 'package:images_files_checker/src/domain/assets_entries/models/image_resolution.dart';
import 'package:images_files_checker/src/domain/checkers/models/analyse_result_error.dart';

class AssetEntry {
  final String fileName;
  final Map<AssetDensity, ImageResolution?> detectedResolutions = {};
  final List<AnalyseResultError> errors = [];

  bool get hasErrors => errors.isNotEmpty;

  AssetEntry({required this.fileName});
}

extension AssetEntries on List<AssetEntry> {
  AssetEntry _getOrAdd(String fileName) {
    return firstWhere((element) => element.fileName == fileName, orElse: () {
      final entry = AssetEntry(fileName: fileName);
      add(entry);
      return entry;
    });
  }

  /// Finds the asset entry and adds the detected density to it. Add a new asset entry if it doesn't exist.
  void addDetectedDensity(String fileName, AssetDensity assetDensity, ImageResolution imageResolution) {
    final image = _getOrAdd(fileName);
    image.detectedResolutions[assetDensity] = imageResolution;
  }

  /// Finds the asset entry and adds the error to it. Add a new asset entry if it doesn't exist.
  void registerError(String fileName, AnalyseResultError error) {
    _getOrAdd(fileName).errors.add(error);
  }
}
