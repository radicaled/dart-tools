AnalysisComponent = require './analysis_component'
AnalysisView = require './views/analysis_view'
Utils = require './utils'
Formatter = require './formatter'
PubComponent = require './pub_component'
PubStatusView = require('./views/pub_status_view')

module.exports =
  # spooky ( ͡° ͜ʖ ͡°)
  analysisComponent: null
  analysisStatusView: null

  pubComponent: null
  pubStatusView: null


  # Wizardry
  configDefaults:
    automaticPubGet: true
    dartSdkLocation: ''

  # TODO: becoming massive, refactor.
  activate: (state) ->
    @pubComponent = new PubComponent(atom.project.getRootDirectory().getPath())
    @pubStatusView = new PubStatusView()

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
