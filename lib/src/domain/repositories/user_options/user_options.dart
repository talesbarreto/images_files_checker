class UserOptions {
  final String imagePath;
  final List<String> expectedResolutions;
  final List<String> supportedFiles;

  const UserOptions({
    required this.imagePath,
    required this.expectedResolutions,
    required this.supportedFiles,
  });
}
