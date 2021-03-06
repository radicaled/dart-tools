{CompositeDisposable} = require 'atom'
{Emitter} = require 'event-kit'
Utils = require './utils'
AutoCompletePlusProvider = require './autocomplete/provider'
_ = require 'lodash'
SdkService = require './sdk/sdk_service'

class DartTools
  subscriptions: new CompositeDisposable()
  hasBooted: false

  constructor: ->
    AnalysisComponent = require './analysis_component'
    @analysisComponent = new AnalysisComponent()
    @analysisApi = @analysisComponent.analysisAPI
    @emitter = new Emitter()

  waitForDartSources: =>
    analysisServer = @analysisComponent.analysisServer
    # Trigger analysis server if we're in a plain-jane Dart project
    @subscriptions.add atom.workspace.observeTextEditors (editor) =>
      enableAnalyzer = (editor) =>
        return unless Utils.canAnalyze(editor)

        projectPath = Utils.findProjectRootInAtom(editor.getPath())
        roots = @analysisComponent.analysisServer.currentAnalysisRoots

        array = []
        perform = =>
          analysisServer.setAnalysisRoots array

        return if roots.has(projectPath)

        roots.add(projectPath)
        roots.forEach (e) => array.push(e)

        if analysisServer.isRunning
          perform()
        else
          sub = @analysisApi.on 'server.connected', =>
            perform()
            sub.dispose()
        @boot()

      editor.onDidChangePath (path) =>
        enableAnalyzer(editor)

      enableAnalyzer(editor)

  consumeLinter: (@linter) =>
    LinterComponent = require './linter/linter_component'
    setupLinter = =>
      @linterComponent = new LinterComponent(@linter, @errorRepository)
    if @hasBooted
      setupLinter()
    else
      @onBoot => setupLinter()

  detectLinterStatus: =>
    unless @linterComponent?.linter
      LinterComponent = require './linter/linter_component'
      LinterComponent.warn()

  # TODO: becoming massive, refactor.
  boot: =>
    return if @hasBooted

    # HACK: for some reason Atom is saving every dart-tools marker
    # This code flushes all pre-existing markers...
    atom.workspace.observeTextEditors (editor) =>
      markers = editor.findMarkers
        isDartMarker: true
      marker.destroy() for marker in markers

    Formatter = require './formatter'
    PubComponent = require './pub/pub_component'
    DartExplorerComponent = require './dart_explorer/dart_explorer_component'
    # AnalysisToolbar = require './analysis/analysis_toolbar'
    ErrorRepository = require './errors/error_repository'
    SdkInfo = require './sdk/sdk_info'
    # AnalysisDecorator = require './analysis/analysis_decorator'
    QuickInfoView = require './info/quick_info_view'
    # ProblemView = require './info/problem_view'
    ContextView = require './info/context_view'
    RefactoringComponent = require './refactoring/refactoring_component'
    # NavigationComponent = require './navigation/navigation_component'

    @errorRepository = new ErrorRepository(@analysisApi)
    # @analysisToolbar = new AnalysisToolbar(@errorRepository)
    @pubComponent = new PubComponent()
    # @dartExplorerComponent = new DartExplorerComponent(@analysisComponent)
    @sdkInfo = new SdkInfo()
    # @analysisDecorator = new AnalysisDecorator(@errorRepository)
    @quickInfoView = new QuickInfoView()
    @formatter = new Formatter(@analysisApi)
    # ProblemView.register(@errorRepository)
    @contextView = new ContextView(@analysisApi)
    @refactoringComponent = new RefactoringComponent(@analysisApi)
    # @navigationComponent = new NavigationComponent(@analysisApi)

    @analysisComponent.enable()
    @refactoringComponent.enable()
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

    unless SdkService.getActiveSdkPath()
      info = '[dart-tools] Dart SDK not specified, analysis_server not running.'
      atom.notifications.addInfo info,
        detail: 'Go to Settings > Packages > Dart Tools to specify Dart SDK'

    setTimeout(
      => @detectLinterStatus(),
      4000)


    # Commands
    atom.commands.add 'atom-workspace', 'dart-tools:format-code', =>
      Utils.whenEditor (editor) =>
        editor.save()
        @formatter.formatEditor(editor)

    atom.commands.add 'atom-workspace', 'dart-tools:sdk-info', =>
      Utils.dartSdkInfo (sdkInfo) =>
        @sdkInfo.showInfo(sdkInfo)

    # Notify listeners that dart-tools has booted
    @hasBooted = true
    @emitter.emit 'boot'

  registerGlobalCommands: =>
    Stagehand = require './stagehand/stagehand'
    atom.commands.add 'atom-workspace', 'dart-tools:stagehand', =>
      Utils.whenDartSdkFound =>
        if atom.project.getPaths().length is 0
          atom.notifications.addInfo(
            "[dart-tools] There is no open project to run Stagehand against."
          )
          return
        atom.notifications.addInfo '[dart-tools] Activating Stagehand...'
        Stagehand.activate().then =>
          Stagehand.showProjectTemplates().then (projectTemplate) =>
            Stagehand.generate(projectTemplate)

  onBoot: (callback) =>
    @emitter.on 'boot', callback

  dispose: =>
    @subscriptions?.dispose()
    @analysisComponent?.disable()
    @analysisDecorator?.dispose()
    @quickInfoView?.dispose()
    @analysisToolbar?.dispose()
    @contextView?.dispose()
    @refactoringComponent?.disable()
    @navigationComponent?.disable()

module.exports = DartTools
