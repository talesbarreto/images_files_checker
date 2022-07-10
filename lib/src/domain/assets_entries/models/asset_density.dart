import 'package:images_files_checker/src/extensions/string.dart';

class AssetDensity implements Comparable<AssetDensity> {
  final int _wholeNumber;
  final int _fractionalPart;

  const AssetDensity(this._wholeNumber, this._fractionalPart);

  factory AssetDensity.fromString(String string) {
    String getParserExceptionError() => "Can not parse $string to AssetDensity";

    if (!string.endsWith("x")) {
      throw Exception(getParserExceptionError());
    }
    final segments = string.removeSuffix('x').split(".");
    if (segments.length == 2) {
      return AssetDensity(int.parse(segments[0]), int.parse(segments[1]));
    }
    throw Exception(getParserExceptionError());
  }

  @override
  String toString() => "$_wholeNumber.${_fractionalPart}x";

  @override
  bool operator ==(Object? other) {
    return other is AssetDensity &&
        other._wholeNumber == _wholeNumber &&
        other._fractionalPart == _fractionalPart;
  }

  @override
  int get hashCode => _wholeNumber * 1000 + _fractionalPart;

  @override
  int compareTo(AssetDensity other) {
    return hashCode - other.hashCode;
  }
}
