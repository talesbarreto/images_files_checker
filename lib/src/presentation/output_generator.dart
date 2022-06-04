import 'package:images_files_checker/src/domain/checkers/models/image_files_checker_result.dart';

class OutputGenerator {
  final void Function(String text) printLine;

  const OutputGenerator(this.printLine);

  void call(List<ImageFilesCheckerResult> result, bool printNoErrorFoundMessages) {
    if (result.isEmpty) {
      printLine('No error found 👍');
      return;
    }

    final buffer = StringBuffer();
    for (final result in result) {
      buffer.clear();
      if (result.errors.isEmpty && printNoErrorFoundMessages) {
        buffer.write('\nNo error found for ${result.imageFileName}');
      } else if (result.errors.isNotEmpty) {
        buffer.write('\n${result.imageFileName}');
        for (final error in result.errors) {
          switch (error.runtimeType) {
            case MissingFileError:
              error as MissingFileError;
              buffer.write('\n\t- missing file for ${error.resolutionName}');
              break;
            case ComparisonFail:
              error as ComparisonFail;
              buffer.write("\n\t- Resolution (${error.resolution}) for ${error.resolutionName} is ");

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
              buffer.write(" ${error.comparedImageFileResolutionName} (${error.comparedImageFileResolution})");
              break;
            default:
              throw Exception('Unknown error type ${error.runtimeType}');
          }
        }
      }
      if (buffer.isNotEmpty) {
        printLine(buffer.toString());
      }
    }
  }
}
