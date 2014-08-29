## 0.7.5

* Better handling of "absent" Dart SDKs
* Added Dart Tools: Sdk Info command
* Now show error message if dart-tools cannot locate `dart`

## 0.7.4
BUGFIX
------
* Decorators are now refreshed properly when analysis results change.

## 0.7.3
BUGFIX
------
* Error and info decorations are now displayed for new editor windows.

## 0.7.2
BUGFIX
------
* Fixed some bugs resolving bug counts.
* Fixed some bugs resolving duplicate items in analysis view.
* Changed terminology from "problems" to "issues"

## 0.7.1
BUGFIX
------
* Now using correct lengths for decorators in the editor UI.

## 0.7.0
BREAKING CHANGE
---------------
In order to analyze your project, you must specify your Dart SDK
location by setting the 'dart-tools.dartSdkLocation' configuration variable
(Settings View: Open -> Filter Packages -> Dart Tools) or by setting a
DART_SDK environment variable.

* Analysis feature now powered by Dart analysis server.

## 0.6.0
* Added "Pub Get" to command palette
* Added setting to automatically run Pub Get on pubspec.yaml change.

## 0.5.0
* Better dealing with output from `dartanalyzer`
* Can now format code via command palette, keyword "Format"
* Free internal decorator array
* More colorization options for Dart analyzer categories

## 0.4.0
* Remove decorations once a problem has been solved.
* dart-tools doesn't generate a console error when Atom has opened a non-dart
  project.
* Can now analyze a .dart file on demand (Dart Tools: Analyze)

## 0.1.0 - First Release
* Every feature added
* Every bug fixed
