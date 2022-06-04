import 'dart:io';

import 'package:images_files_checker/src/domain/common/result.dart';
import 'package:images_files_checker/src/domain/repositories/image_metadata/image_metadata_repository.dart';
import 'package:images_files_checker/src/domain/repositories/image_metadata/models/image_resolution.dart';

class FakeImageMetadataRepository implements ImageMetadataRepository {
  final ImageResolution? answer;
  final Map<String, Result<ImageResolution>> answers;

  const FakeImageMetadataRepository.defaultAnswer(this.answer) : answers = const {};

  const FakeImageMetadataRepository(this.answers) : answer = null;

  @override
  Future<Result<ImageResolution>> getImageResolution(File file) async {
    final result = answer != null ? ResultSuccess(answer!) : answers[file.path];
    if (result == null) {
      throw Exception('No answer for ${file.path}');
    }
    return result;
  }
}
