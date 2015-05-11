url = require 'url'

module.exports =
class DartExplorerComponent
  uri: 'dart-tools://dart_explorer/'

  constructor: (@analysisComponent) ->

  enable: =>
    atom.workspace.registerOpener (uriToOpen) =>
      try
        {protocol, host, pathname} = url.parse(uriToOpen)
      catch error
        return

      return unless protocol == 'dart-tools:'
      return unless host == 'dart_explorer'

      DartExplorerView = require './dart_explorer_view'
      new DartExplorerView(atom.project, @analysisComponent.analysisAPI)

    atom.commands.add 'atom-workspace', 'dart-tools:dart-explorer', =>
      atom.workspace.open(@uri, split: 'right')

  disable: =>
    # NO OP?
