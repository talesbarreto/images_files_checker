import 'dart:io';

import 'package:args/args.dart';
import 'package:images_files_checker/src/data/image_files/image_files_repository_impl.dart';
import 'package:images_files_checker/src/data/image_metadata/image_metadata_repository_impl.dart';
import 'package:images_files_checker/src/data/user_options/user_options_repository_impl.dart';
import 'package:images_files_checker/src/domain/checkers/image_files_checker.dart';
import 'package:images_files_checker/src/domain/common/result.dart';
import 'package:images_files_checker/src/domain/repositories/image_files/image_files_repository.dart';
import 'package:images_files_checker/src/domain/repositories/image_metadata/image_metadata_repository.dart';
import 'package:images_files_checker/src/domain/repositories/user_options/user_options.dart';
import 'package:images_files_checker/src/domain/repositories/user_options/user_options_repository.dart';
import 'package:images_files_checker/src/presentation/output_generator.dart';

Future<void> main(List<String> arguments) async {
  final UserOptionsRepository argsRepository = UserOptionsRepositoryImpl(ArgParser());
  final ImageMetadataRepository imageMetadataDataSource = ImageMetadataRepositoryImpl();
  final ImageFilesRepository imageFilesRepository = ImageFilesRepositoryImpl();

  final userOptions = argsRepository.getUserOptions(arguments);
  if (userOptions is ResultSuccess<UserOptions>) {
    final Result<List<File>> files = await imageFilesRepository.getImageFiles(userOptions.data.imagePath);

    if (files is! ResultSuccess<List<File>>) {
      files as ResultError<List<File>>;
      print(files.message);
      exit(-1);
    }

    final checker = ImageFilesChecker(files: files.data, userOptions: userOptions.data, imageMetadataDataSource: imageMetadataDataSource);
    final errors = await checker.call();
    final outputGenerator = OutputGenerator(print);

    outputGenerator(errors, false);
    exit(errors.isEmpty ? 0 : 1);
  } else if (userOptions is ResultError<UserOptions>) {
    print("Error: ${userOptions.message}");
    exit(-1);
  }
}
