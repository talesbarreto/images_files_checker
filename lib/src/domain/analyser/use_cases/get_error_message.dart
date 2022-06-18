import 'package:images_files_checker/src/domain/assets_entries/models/asset_entries.dart';
import 'package:images_files_checker/src/domain/checkers/models/decode_error.dart';
import 'package:images_files_checker/src/domain/checkers/models/image_resolution_error.dart';
import 'package:images_files_checker/src/domain/checkers/models/missing_file_error.dart';

class GetErrorMessage {
  String? call(AssetEntry assetEntry) {
    final buffer = StringBuffer();
    if (assetEntry.errors.isNotEmpty) {
      buffer.write('\n${assetEntry.fileName}');
      for (final error in assetEntry.errors) {
        switch (error.runtimeType) {
          case MissingFileError:
            error as MissingFileError;
            buffer.write('\n\t- missing file for ${error.assetDensity}');
            break;
          case ComparisonFail:
            error as ComparisonFail;
            buffer.write("\n\t- Resolution (${error.targetFile.second}) for ${error.targetFile.first} is ");

            switch (error.comparisonFailType) {
              case ComparisonFailType.smaller:
                buffer.write('smaller than');
                break;
              case ComparisonFailType.bigger:
                buffer.write('greater than');
                break;
              case ComparisonFailType.equal:
                buffer.write('equals to');
                break;
            }
            buffer.write(" ${error.comparedFile.first} (${error.comparedFile.second})");
            break;
          case DecodeError:
            error as DecodeError;
            buffer.write('\n\t- ${error.message}');
            break;
          default:
            throw Exception('Unknown error type ${error.runtimeType}');
        }
      }
    }
    return buffer.isNotEmpty ? buffer.toString() : null;
  }
}
