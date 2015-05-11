Utils = require './utils'
AutoCompletePlusProvider = require './autocomplete/provider'

module.exports =
  
  # Wizardry
  config:
    automaticPubGet:
      type: 'boolean'
      default: true
    dartSdkLocation:
      type: 'string'
      default: ''


  # Provider for `autocomplete-plus`
  provideAutocompleter: ->
    AutoCompletePlusProvider


  # TODO: becoming massive, refactor.
  activate: (state) ->
    return unless Utils.isDartProject()

    AnalysisComponent = require './analysis_component'
    Formatter = require './formatter'
    PubComponent = require './pub/pub_component'
    DartExplorerComponent = require ('./dart_explorer/dart_explorer_component')
    AnalysisToolbar = require './analysis/analysis_toolbar'
    ErrorRepository = require './errors/error_repository'
    SdkInfo = require('./sdk/sdk_info')

    @analysisComponent = new AnalysisComponent()

    @errorRepository = new ErrorRepository(@analysisComponent.analysisAPI)
    @analysisToolbar = new AnalysisToolbar(@errorRepository)
    @pubComponent = new PubComponent(atom.project.getPaths()[0])
    @dartExplorerComponent = new DartExplorerComponent(@analysisComponent)
    @sdkInfo = new SdkInfo()

    @analysisComponent.enable()
    AutoCompletePlusProvider.analysisApi = @analysisComponent.analysisAPI
    # @dartExplorerComponent.enable()

    atom.commands.add 'atom-workspace', 'dart-tools:format-code', =>
      Utils.whenEditor (editor) ->
        editor.save()
        Formatter.formatCode(editor.getPath())

    atom.commands.add 'atom-workspace', 'dart-tools:sdk-info', =>
      Utils.dartSdkInfo (sdkInfo) =>
        @sdkInfo.showInfo(sdkInfo)

    atom.commands.add 'atom-workspace', 'dart-tools:toggle-analysis-view'

  deactivate: ->
    @analysisComponent.disable()

  serialize: ->
