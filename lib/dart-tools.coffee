Utils = require './utils'

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
    return unless Utils.isDartProject()

    AnalysisComponent = require './analysis_component'
    Formatter = require './formatter'
    PubComponent = require './pub/pub_component'
    DartExplorerComponent = require ('./dart_explorer/dart_explorer_component')
    AutocompleteComponent = require './autocomplete/autocomplete_component'

    @analysisComponent = new AnalysisComponent()
    @pubComponent = new PubComponent(atom.project.getRootDirectory().getPath())
    @dartExplorerComponent = new DartExplorerComponent(@analysisComponent)
    @autocompleteComponent = new AutocompleteComponent(@analysisComponent)


    @analysisComponent.enable()
    # @dartExplorerComponent.enable()
    @autocompleteComponent.enable()

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

    atom.workspaceView.command 'dart-tools:sdk-info', =>
      Utils.dartSdkInfo (sdkInfo) =>
        atom.workspace.emit 'dart-tools:show-sdk-info', sdkInfo

    atom.workspaceView.command 'dart-tools:toggle-analysis-view'

    atom.workspace.on 'dart-tools:cannot-find-sdk', (sdkInfo) =>
      Sdk404View = require('./views/sdk_404_view')
      atom.workspaceView.prependToBottom(new Sdk404View(sdkInfo))

    atom.workspace.on 'dart-tools:show-sdk-info', (sdkInfo) =>
      SdkInfoView = require('./views/sdk_info_view')
      atom.workspaceView.prependToBottom(new SdkInfoView(sdkInfo))

  deactivate: ->
    @analysisComponent.disable()

  serialize: ->
