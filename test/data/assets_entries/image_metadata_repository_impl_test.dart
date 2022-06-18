import 'dart:io';

import 'package:images_files_checker/src/data/assets_entries/image_metadata_repository_impl.dart';
import 'package:images_files_checker/src/domain/assets_entries/models/asset_density.dart';
import 'package:images_files_checker/src/domain/assets_entries/models/image_resolution.dart';
import 'package:images_files_checker/src/domain/assets_entries/repositories/image_metadata_repository.dart';
import 'package:images_files_checker/src/domain/common/result.dart';
import 'package:test/test.dart';
import 'package:image/image.dart' as image_lib;

void main() {
  Future<image_lib.Image?> fakeDecoderToNull(File file) async => null;

  group("When `getImageResolution` is invoked", () {
    test("return the file resolution", () async {
      const filePath = "/hahaha/wow.png";
      File? decodedFile;
      final decodedImage = image_lib.Image(1, 2);

      Future<image_lib.Image?> fakeDecoder(File file) async {
        decodedFile = file;
        return decodedImage;
      }

      final repository = ImageMetadataRepositoryImpl(fakeDecoder);

      final result = await repository.getImageResolution(File(filePath));

      expect(decodedFile?.path, equals(filePath));
      expect(result, isA<ResultSuccess<ImageResolution>>());
      result as ResultSuccess<ImageResolution>;
      expect(result.data, equals(ImageResolution(width: 1, height: 2)));
    });

    test("return a ResultError if decoder returns null", () async {
      final repository = ImageMetadataRepositoryImpl(fakeDecoderToNull);

      final result = await repository.getImageResolution(File("/hahaha/wow.png"));

      expect(result, isA<ResultError<ImageResolution>>());
    });
  });

  group("when `getImagePixelDensity` is invoked", () {
    test("return defaultDensity if file is in the root of assets dir", () {
      final repository = ImageMetadataRepositoryImpl(fakeDecoderToNull);
      final result = repository.getImagePixelDensity(File("/hahaha/wow.png"), "/hahaha") as ResultSuccess<AssetDensity>;
      expect(result.data, equals(ImageMetadataRepository.defaultDensity));
    });

    test("return 2.0 if file is in `2.0x` sub dir", () {
      final repository = ImageMetadataRepositoryImpl(fakeDecoderToNull);
      final result = repository.getImagePixelDensity(File("/hahaha/2.0x/wow.png"), "/hahaha") as ResultSuccess<AssetDensity>;
      expect(result.data, equals(AssetDensity(2, 0)));
    });

    test("return ResultError if file is in `Rammstein` sub dir", () {
      final repository = ImageMetadataRepositoryImpl(fakeDecoderToNull);
      final result = repository.getImagePixelDensity(File("/hahaha/Rammstein/wow.png"), "/hahaha");
      expect(result, isA<ResultError<AssetDensity>>());
    });
  });
}
