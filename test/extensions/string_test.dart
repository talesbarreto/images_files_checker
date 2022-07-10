import 'package:images_files_checker/src/extensions/string.dart';
import 'package:test/test.dart';

void main() {
  test("When 'BlaBlablaHa'.removeSuffix('p') is invoked, return 'BlaBlablaHa'",
      () {
    expect('BlaBlablaHa'.removeSuffix('p'), equals("BlaBlablaHa"));
  });
  test("When 'BlaBlablaHa'.removeSuffix('Ha') is invoked, return 'BlaBlabla'",
      () {
    expect('BlaBlablaHa'.removeSuffix('Ha'), equals("BlaBlabla"));
  });
  test("When 'BlaBlablaHa'.removeSuffix('a') is invoked, return 'BlaBlablaH'",
      () {
    expect('BlaBlablaHa'.removeSuffix('a'), equals("BlaBlablaH"));
  });
}
