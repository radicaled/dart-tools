## 0.8.5

* Items in the analysis issue list can now be clicked on. They will open the
relevant file and bring the cursor to the start of the issue.
* Analysis View now appears above status bar.
* 'Toggle Analysis View' command will toggle analysis issue view. It can be
bound with the command 'dart-tools:toggle-analysis-view'


## 0.8.4

* Quick issue view now updates live as analysis results are updated under the
cursor.

## 0.8.3

* Minor performance improvements.

## 0.8.2

* Added autocomplete based on analysis_server package.
  NOTE: the results usually hit the barn wall.

## 0.8.1

* Added Quick Issue View: displays Dart warnings / errors underneath
the current cursor position.

## 0.8.0 -- THE VERSION TIME FORGOT

Just me fat fingering `apm minor` instead of `apm publish`

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
