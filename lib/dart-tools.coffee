{CompositeDisposable} = require 'atom'
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
    @subscriptions = new CompositeDisposable()
    # HACK: for some reason Atom is saving every dart-tools marker
    # This code flushes all pre-existing markers...
    atom.workspace.observeTextEditors (editor) =>
      markers = editor.findMarkers
        isDartMarker: true
      marker.destroy() for marker in markers

    # Status updates for analysis server

    AnalysisComponent = require './analysis_component'
    Formatter = require './formatter'
    PubComponent = require './pub/pub_component'
    DartExplorerComponent = require './dart_explorer/dart_explorer_component'
    AnalysisToolbar = require './analysis/analysis_toolbar'
    ErrorRepository = require './errors/error_repository'
    SdkInfo = require './sdk/sdk_info'
    AnalysisDecorator = require './analysis/analysis_decorator'
    QuickInfoView = require './info/quick_info_view'
    ProblemView = require './info/problem_view'

    @analysisComponent = new AnalysisComponent()
    @analysisApi = @analysisComponent.analysisAPI

    @errorRepository = new ErrorRepository(@analysisApi)
    @analysisToolbar = new AnalysisToolbar(@errorRepository)
    @pubComponent = new PubComponent(atom.project.getPaths()[0])
    # @dartExplorerComponent = new DartExplorerComponent(@analysisComponent)
    @sdkInfo = new SdkInfo()
    @analysisDecorator = new AnalysisDecorator(@errorRepository)
    @quickInfoView = new QuickInfoView()

    ProblemView.register(@errorRepository)

    @analysisComponent.enable()
    AutoCompletePlusProvider.analysisApi = @analysisApi
    # @dartExplorerComponent.enable()



    # Status updates for analysis server
    @analysisApi.on 'server.connected', =>
      success = '[dart-tools] The analysis server is now running.'
      atom.notifications.addSuccess success
    @analysisApi.on 'server.error', =>
      warning = '
        [dart-tools] The analysis server has experienced an error.
        Please restart Atom and hope that fixes it.
      '
      atom.notifications.addWarning warning

    # Commands

    atom.commands.add 'atom-workspace', 'dart-tools:format-code', =>
      Utils.whenEditor (editor) ->
        editor.save()
        Formatter.formatCode(editor.getPath())

    atom.commands.add 'atom-workspace', 'dart-tools:sdk-info', =>
      Utils.dartSdkInfo (sdkInfo) =>
        @sdkInfo.showInfo(sdkInfo)

    atom.commands.add 'atom-workspace', 'dart-tools:toggle-analysis-view'

  deactivate: ->
    @subscriptions.dispose()
    @analysisComponent.disable()
    @analysisDecorator.dispose()
    @quickInfoView.dispose()
