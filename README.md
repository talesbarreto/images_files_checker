![flutter-ci](https://github.com/talesbarreto/images_files_checker/actions/workflows/flutter-ci.yml/badge.svg)

A CI tool that verifies assets image files in the project.

## Features
- Checks if each image has all expected resolutions files.
- Report wrong image resolution.

## Usage
```bash
flutter pub run images_files_checker --path assets/images --unexpected-dir-is-an-error
```

| Parameter   | default                    | mandatory | description                           |
|-------------|----------------------------|-----------|---------------------------------------|
| path        |                            | yes       | Assets image files directory          |
| resolutions | 1.0x,1.5x,2.0x,3.0x,4.0x   | no        | Expected densities                    |
| extensions  | jpeg,webp,png,gif,bmp,wbmp | no        | Image extensions that will be checked |

| Flags                      | description                                                                      |
|----------------------------|----------------------------------------------------------------------------------|
| unexpected-dir-is-an-error | If a image is in a subdir that doesn't fallow the pattern `#.#x`, test will fail |
| decoding-error-is-an-error | Images that failed to decode, test will fail                                     |
    

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

## Exit code
- 0 no errors found
- 1 test fail
- 255 error

## Installation
This is an alpha version. The only way to install it is adding to your `pubspec.yaml`:

```yaml
dev_dependencies:
  images_files_checker:
    git:
      url: git@github.com:talesbarreto/images_files_checker.git
      ref: main
```
