import 'package:images_files_checker/src/domain/checkers/models/analyse_result_error.dart';

/// This error means that it was not possible to decode the image using `image` package
class ImageDecodeError implements AnalyseResultError {
  final String filePath;
  final Object? error;
  final StackTrace? stackTrace;

  const ImageDecodeError(this.filePath, this.error, this.stackTrace);
}
