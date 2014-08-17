# dart-tools package

Various tools for Dart support in Atom.

**NOTE**: very alpha quality

Features
========

* Lints the current Dart file, on change, when a pubspec.yaml file exists
at project root. (see note section)
* Lints the current Dart file via command palette. (see note section)
* Formats the current Dart file via command palette, supporting both whitespace-only
and code transformation.
* Automatic and manual "pub get."

Notes
=====

Linting and formatting will save the current editor buffer first.

**Linting requires you to set your dart-sdk location.** You can do it inside Atom
(Settings View: Open -> Filter Packages -> Dart Tools) or set a DART_SDK
environment variable.
