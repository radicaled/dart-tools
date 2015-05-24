# dart-tools package

[![Build Status](https://travis-ci.org/radicaled/dart-tools.svg?branch=master)][travis]

Various tools for Dart support in Atom.

**NOTE**: somewhat alpha quality

Features
========

* Updated grammar file (no need for the `language-dart` package; remove it if you have it)
* Lints the Dart project when a pubspec.yaml file exists
at project root. (see note section)
* Formats the current Dart file via command palette
* Can perform "pub get" when pubspec.yaml is saved.
* Can format Dart files on save.
* Putting the caret within an analysis error quickly shows the problem text
* Basic autocomplete, via the `autocomplete-plus` package.

Available Commands
==================

* Pub Get
* Pub Upgrade
* Sdk Info
* Format Code

Notes
=====

Formatting will save the current editor buffer first.

**Linting requires you to set your dart-sdk location.** You can do that from
`Settings View: Open` -> `Filter Packages` -> `Dart Tools`.

If you have a `pubspec.yaml` file or `.packages` path in your project, linting
will begin immediately. If not, linting will begin once you open a Dart file
that exists within your current project scope.

Performance: `dart-tools` doesn't handle a large number of errors very well -
around 300 errors starts slowing things down. Take care with your refactoring
until this is resolved!

Credits
=======

dart.cson taken from https://github.com/Daegalus/atom-language-dart (dead?) and modified.

[travis]: https://travis-ci.org/radicaled/dart-tools
