AnalysisServer = require './analysis_server'
AnalysisView = require './views/analysis_view'
AnalysisAPI = require './analysis_api'
BufferUpdateComponent = require './buffer_update_component'
Utils = require './utils'
{Emitter} = require 'event-kit'

spawn = require('child_process').spawn
extname = require('path').extname

module.exports =
class AnalysisComponent
  subscriptions: []
  analysisView: null
  analysisServer: null
  analysisAPI: new AnalysisAPI()

  quickIssueView: null

  constructor: ->
    @emitter = new Emitter()

  enable: =>
    @subscriptions.push atom.project.onDidChangePaths @watchDartProject
    @watchDartProject()
    # @createAnalysisView()
    # @createQuickIssueView()

    atom.workspace.observeTextEditors (editor) =>
      new BufferUpdateComponent(editor, @analysisAPI)

  disable: =>
    @cleanup()

  watchDartProject: =>
    @cleanup()

    return unless Utils.isDartProject()

    rootPath = atom.project.getPaths()[0]
    @analysisServer = new AnalysisServer(rootPath)
    @analysisAPI.analysisServer = @analysisServer

    @analysisServer.start rootPath

  checkFile: (fullPath) =>
    if extname(fullPath) == '.dart'
      @analysisServer.check(fullPath)

  cleanup: =>
    subscription.dispose() for subscription in @subscriptions
    @subscriptions = []
    @watcher?.close()
    @analysisServer?.stop()

  createAnalysisView: =>
    atom.packages.once 'activated', =>
      @analysisView = new AnalysisView()
      @analysisView.attach()

  createQuickIssueView: =>
    QuickIssueView = require './views/quick_issue_view'
    qv = new QuickIssueView()
    atom.workspaceView.appendToBottom(qv)

    atom.workspace.eachEditor (editor) ->
      qv.watchEditor(editor)

  showProblems: =>
    console.log 'showing problems'
