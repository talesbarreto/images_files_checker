![example workflow](https://github.com/talesbarreto/images_files_checker/actions/workflows/flutter-ci.yml/badge.svg)

A CI tool that verifies assets image files in the project.

## Features
- Checks if each image has all expected resolutions files.
- Report wrong image resolution.

## usage
```bash
flutter pub run images_files_checker --path assets/images
```
| Parameter         | default                    | mandatory | description                  |
|-------------------|----------------------------|-----------|------------------------------|
| path              |                            | yes       | assets image files directory |
| resolutions       | 1.0x,1.5x,2.0x,3.0x,4.0x   | no        | expected resolutions         |
| supported-formats | jpeg,webp,png,gif,bmp,wbmp | no        | Files that should be checked |

#### Output example:
```
cat.webp
        - Resolution (61x60) for 2.0x is smaller than 1.5x (80x80)

dog.webp
        - missing file for 1.5x
        - missing file for 2.0x
        - missing file for 3.0x
        - missing file for 4.0x
```

## Installation
This is an alpha version. The only way to install it is adding to your `pubspec.yaml`:

```yaml
dev_dependencies:
  images_files_checker:
    git:
      url: git@github.com:talesbarreto/images_files_checker.git
      ref: main
```
## Usage examples

```dart
const like = 'sample';
```

## Additional information

TODO: Tell users more about the package: where to find more information, how to 
contribute to the package, how to file issues, what response they can expect 
from the package authors, and more.
