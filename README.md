# dart-tools package

Various tools for Dart support in Atom.

**NOTE**: somewhat alpha quality

Features
========

* Updated grammar file (no need for the `language-dart` package; remove it if you have it)
* Lints the current Dart file when a pubspec.yaml file exists
at project root. (see note section)
* Formats the current Dart file via command palette
* Automatic and manual "pub get."
* Putting a cursor within an analysis error quickly shows the problem text
* Basic autocomplete, via the `autocomplete-plus` package.

Available Commands
==================

* Pub Get
* Sdk Info
* Format Code

Notes
=====

Formatting will save the current editor buffer first.

**Linting requires you to set your dart-sdk location.** You can do from
Settings View: Open -> Filter Packages -> Dart Tools.

Linting will not be performed until you have run `pub get` at least once.

Performance: `dart-tools` doesn't handle a large number of errors very well -- around 300 errors starts slowing things down. Take care with your refactoring until this is resolved!


Credits
=======

dart.cson taken from https://github.com/Daegalus/atom-language-dart (dead?) and modified.
