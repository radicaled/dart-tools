{WorkspaceView} = require 'atom'
DartTools = require '../lib/dart-tools'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "DartTools", ->
  activationPromise = null

  beforeEach ->
    atom.workspaceView = new WorkspaceView
    activationPromise = atom.packages.activatePackage('dart-tools')

  describe "when the dart-tools:toggle event is triggered", ->
    it "attaches and then detaches the view", ->
      expect(atom.workspaceView.find('.dart-tools')).not.toExist()

      # This is an activation event, triggering it will cause the package to be
      # activated.
      atom.workspaceView.trigger 'dart-tools:toggle'

      waitsForPromise ->
        activationPromise

      runs ->
        expect(atom.workspaceView.find('.dart-tools')).toExist()
        atom.workspaceView.trigger 'dart-tools:toggle'
        expect(atom.workspaceView.find('.dart-tools')).not.toExist()
