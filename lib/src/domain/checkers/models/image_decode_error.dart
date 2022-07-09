import 'package:images_files_checker/src/domain/checkers/models/analyse_result_error.dart';

/// This error means that it was not possible to decode the image using `image` package
class ImageDecodeError implements AnalyseResultError {
  final String fileName;
  final String message;

  const ImageDecodeError(this.fileName, this.message);

}
