extension Remove on String {
  String removePrefix(String prefix) {
    if (startsWith(prefix)) {
      return replaceFirst(prefix, "");
    }
    return this;
  }

  String removeSuffix(String prefix) {
    if (endsWith(prefix)) {
      return substring(0, length - prefix.length);
    }
    return this;
  }
}
