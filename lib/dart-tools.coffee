AnalysisComponent = require './analysis_component'
AnalysisView = require './views/analysis_view'
Utils = require './utils'
Formatter = require './formatter'

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
      Utils.whenEditor (editor) =>
        editor.save()
        @analysisComponent.checkFile(editor.getPath())
    atom.workspaceView.command 'dart-tools:format-whitespace', =>
      Utils.whenEditor (editor) ->
        editor.save()
        Formatter.formatWhitespace(editor.getPath())
    atom.workspaceView.command 'dart-tools:format-code', =>
      Utils.whenEditor (editor) ->
        editor.save()
        Formatter.formatCode(editor.getPath())

  deactivate: ->
    @analysisComponent.disable()

  serialize: ->
