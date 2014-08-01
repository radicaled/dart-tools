# dart-tools package

Various tools for Dart support in Atom.

**NOTE**: very alpha quality

Features
========

* Lints the current Dart file, on change, when a pubspec.yaml file exists
at project root.
* Lints the current Dart file via command palette.
* Formats the current Dart file via command palette, supporting both whitespace-only
and code transformation.

Notes
=====

Linting and formatting will save the current editor buffer first.


Requires your dart-sdk to be available in your path. Will fail silently otherwise.
