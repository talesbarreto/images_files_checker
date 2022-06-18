import 'package:images_files_checker/src/domain/checkers/models/analyse_result_error.dart';

class DecodeError implements AnalyseResultError {
  final String fileName;
  final String message;

  const DecodeError(this.fileName, this.message);

  @override
  ImageFilesCheckerResultErrorType get errorType => ImageFilesCheckerResultErrorType.executionWarning;
}
