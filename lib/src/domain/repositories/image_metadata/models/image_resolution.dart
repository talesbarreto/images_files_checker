class ImageResolution {
  final int width;
  final int height;

  const ImageResolution({required this.width, required this.height});

  @override
  operator ==(other) {
    return other is ImageResolution && other.width == width && other.height == height;
  }

  operator >(other) {
    return other is ImageResolution && width * height > other.width * other.height;
  }

  operator <(other) {
    return other is ImageResolution && other > this;
  }

  operator >=(other) {
    return other is ImageResolution && (this > other || this == other);
  }

  @override
  String toString() => "${width}x$height";

  @override
  int get hashCode => width.hashCode ^ height.hashCode;
}
