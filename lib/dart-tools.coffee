AnalysisComponent = require './analysis_component'
AnalysisView = require './views/analysis_view'

module.exports =
  # spooky ( ͡° ͜ʖ ͡°)
  analysisComponent: null
  analysisStatusView: null

  activate: (state) ->
    @analysisComponent = new AnalysisComponent()
    @analysisComponent.enable()

    @analysisComponent.on 'dart-tools:refresh', (fullPath) =>
      atom.workspace.emit 'dart-tools:refresh', fullPath
    @analysisComponent.on 'dart-tools:analysis', (result) =>
      atom.workspace.emit 'dart-tools:analysis', result

    atom.workspaceView.command 'dart-tools:analyze-file', =>
      editor = atom.workspace.getActiveEditor()
      if editor
        @analysisComponent.checkFile(editor.getPath())

  deactivate: ->
    @analysisComponent.disable()

  serialize: ->
