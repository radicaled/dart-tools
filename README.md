# dart-tools package

Various tools for Dart support in Atom.

**NOTE**: somewhat alpha quality

Features
========

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
