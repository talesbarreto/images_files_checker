![flutter-ci](https://github.com/talesbarreto/images_files_checker/actions/workflows/flutter-ci.yml/badge.svg)

A CI step tool that verifies assets image files in the project.

Flutter can load resolution-appropriate images for the current device pixel ratio. To make this work, you need to add several image files for the same image. Each one has a different resolution and should be arranged according to a particular directory structure.

This is a tedious task, and can easily lead to errors. This tool helps you to verify that all the images are properly arranged, checking if each image has all expected files and if those files doesn't have inconsistent resolutions between them.

Check the Flutter docs out to understand how Flutter loads images: [Adding assets and images](https://docs.flutter.dev/development/ui/assets-and-images#loading-images)

## Usage
```bash
flutter pub run images_files_checker --path assets/images --unexpected-dir-is-an-error
```

### Output example:
```
cat.webp
        - Resolution (61x60) for 2.0x is smaller than 1.5x (80x80)

dog.webp
        - missing file for 1.5x
        - missing file for 2.0x
        - missing file for 3.0x
        - missing file for 4.0x
```

## Exit code

| Code | Description                                      |
|------|--------------------------------------------------|
| 0    | All images are properly arranged                 |
| 1    | Inconsistencies were found                       |
| 255  | Execution has failed and tests were not executed |


## Options

| Parameter   | default                    | mandatory | description                           |
|-------------|----------------------------|-----------|---------------------------------------|
| path        |                            | yes       | Assets image files directory          |
| resolutions | 1.0x,1.5x,2.0x,3.0x,4.0x   | no        | Expected densities                    |
| extensions  | jpeg,webp,png,gif,bmp,wbmp | no        | Image extensions that will be checked |

| Flags                      | description                                                                      |
|----------------------------|----------------------------------------------------------------------------------|
| unexpected-dir-is-an-error | If a image is in a subdir that doesn't fallow the pattern `#.#x`, test will fail |
| decoding-error-is-an-error | Images that failed to decode, test will fail                                     |
