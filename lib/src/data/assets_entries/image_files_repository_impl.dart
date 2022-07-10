import 'dart:io';
import 'package:images_files_checker/src/domain/common/result.dart';
import 'package:images_files_checker/src/domain/assets_entries/repositories/image_files_repository.dart';

class ImageFilesRepositoryImpl implements ImageFilesRepository {
  @override
  Future<Result<List<File>>> getImageFiles(String path) async {
    try {
      final dir = Directory(path);
      final List<File> files = [];

      await for (final entity
          in dir.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          files.add(entity);
        }
      }
      return ResultSuccess(files);
    } catch (e) {
      if (e is FileSystemException && e.osError?.errorCode == 2) {
        return ResultError('Directory not found: $path');
      }
      return ResultError(e.toString());
    }
  }
}
