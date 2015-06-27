# 0.9.18

Features:
  * Now using the `linter` package to provide error details. Install it today!
  * Press CTRL-I to get basic dart documentation for element at cursor
  * Basic "rename" refactor available via command palette (Dart Tools: Rename)
  * Some updates to Dart grammar

# 0.9.17

Bugfixes:
  * Doesn't generate error message when closing an editor window.

# 0.9.16

Rogue publish due to issues with `apm publish` and/or Atom API(?)

# 0.9.15

Bugfixes:
  * Resolved an issue in our interaction with analysis_server

# 0.9.14

Bugfixes:
  * Resolved issue with some package UI not being removed on deactivation

# 0.9.13

Features:
  * Generate a new Dart project using Stagehand

Bugfixes:
  * Resolved issue with Dart analyzer sometimes not reporting all errors in file

# 0.9.12

Features:
  * Now supports analyzing plain jane Dart files when possible.
  * When launched from command shell, will try to locate Dart SDK on demand if
    no Dart SDK has been explicitly configured.

General overhaul of the errors display:
  * add a gutter bullet decoration for dart infos, warnings, and errors
  * show the quick error view for any markers on the line (not just the selection)
  * change the look of the quick info view of a dart issue
  * change the highlight decorator to better call out errors (2px underline instead of 1px dotted)

Other:
  * Remove a no longer used `dart-tools:toggle-analysis-view` command
  * Change the SDK and Pub dialogs to model dialogs
  * Added context menu items for running pub and the formatter

Bugfixes:
  * Resolved issue with Dart analyzer sometimes starting up on unsupported
    projects.

# 0.9.11

Features:
  * Better Pub output styling by @devoncarew
  * Pub Upgrade support by @devoncarew
  * Now supports multiple Dart projects in a single Atom workspace

Bugfixes:
  * node-pathwatcher has a bug: it sometimes produces 2 events! We work
    around that bug for now
  * Windows 8.1 x64 support

# 0.9.10

Features:
  Added "pub upgrade" thanks to @devoncarew

Bugfixes:
  Problem View: clicking on a line item now takes you to that location again

Errata:

Some awesome styling changes thanks to @devoncarew
  * The toolbar now has a cleaner look
  * The SDK info dialog now has a cleaner look
  * The Pub dialog how has a cleaner look

## 0.9.9

Bugfixes: manually invoking the formatter no longer raises an error.

## 0.9.8

Bugfixes: work on how paths are composed for better Windows support.

## 0.9.7

dart-tools works under Windows again

## 0.9.6

Problem View: clean up view styling / formatting.

## 0.9.5

Bugfixes: auto formatting does not raise exception on non-Dart files

## 0.9.3

Bugfixes: don't try to reregister custom elements (Github Issue #26)

## 0.9.2

Release for Atom 0.198

## 0.9.1

Updating the most important part of the project: the README.md

Also, use new autocomplete+ type icons when possible

## 0.9.0

Everything old is new again.

dart-tools now uses the analysis_server packaged with the Dart SDK to perform
its code analysis (linting, autocomplete, etc).

Dart 1.10+ required

## 0.8.9

dart-tools no longer crashes when opening a blank Atom window

## 0.8.8

Remove the last of the known deprecations from dart-tools

## 0.8.7

Use the 'atom-text-editor' tag instead of the 'editor' class in dart-tools.cson

## 0.8.6

Update dependencies to handle deprecations.

## 0.8.5 (again)

* Try to more gracefully handle analysis server crashes.

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
