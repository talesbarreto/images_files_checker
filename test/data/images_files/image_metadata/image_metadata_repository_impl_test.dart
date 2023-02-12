import 'dart:io';

import 'package:images_files_checker/src/data/assets_entries/image_metadata_repository_impl.dart';
import 'package:images_files_checker/src/domain/common/result.dart';
import 'package:test/test.dart';
import 'package:image/image.dart' as image_lib;

void main() {
  group("When getImageResolution() is invoked", () {
    test("return the expected ImageResolution", () async {
      final image = image_lib.Image(width: 300, height: 500);
      final repository = ImageMetadataRepositoryImpl((_) async => image);

      final result = await repository.getImageResolution(File("/"));
      expect(result, isA<ResultSuccess>());
// todo
    });
  });
}
