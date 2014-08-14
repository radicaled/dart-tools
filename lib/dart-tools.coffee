AnalysisComponent = require './analysis_component'
AnalysisView = require './views/analysis_view'
Utils = require './utils'
Formatter = require './formatter'
PubComponent = require './pub_component'

module.exports =
  # spooky ( ͡° ͜ʖ ͡°)
  analysisComponent: null
  analysisStatusView: null

  pubComponent: null


  # Wizardry
  configDefaults:
    automaticPubGet: true

  # TODO: becoming massive, refactor.
  activate: (state) ->
    @pubComponent = new PubComponent(atom.project.getRootDirectory().getPath())
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

    atom.workspaceView.command 'dart-tools:pub-get', =>
      @pubComponent.get()


  deactivate: ->
    @analysisComponent.disable()

  serialize: ->
