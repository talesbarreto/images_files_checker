import 'package:images_files_checker/src/domain/checkers/image_checker_result.dart';

class GetErrorMessage {
  String? call(ImageCheckResult result) {
    final buffer = StringBuffer();
    if (result.errors.isNotEmpty) {
      buffer.write('\n${result.imageFileName}');
      for (final error in result.errors) {
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
          default:
            throw Exception('Unknown error type ${error.runtimeType}');
        }
      }
    }
    return buffer.isNotEmpty ? buffer.toString() : null;
  }
}
