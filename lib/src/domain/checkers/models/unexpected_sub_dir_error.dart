import 'package:images_files_checker/src/domain/checkers/models/analyse_result_error.dart';

/// This error means that an image is inside a sub-directory that doesn't match with the pattern `#.#x`,
class UnexpectedSubDirError implements AnalyseResultError {
  final String path;

  const UnexpectedSubDirError(this.path);
}
