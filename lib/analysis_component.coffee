AnalysisServer = require './analysis_server'
AnalysisAPI = require './analysis_api'
BufferUpdateComponent = require './buffer_update_component'
Utils = require './utils'
{Emitter} = require 'event-kit'

spawn = require('child_process').spawn
extname = require('path').extname

module.exports =
class AnalysisComponent
  subscriptions: []
  analysisServer: null
  analysisAPI: new AnalysisAPI()

  constructor: ->
    @emitter = new Emitter()
    @analysisServer = new AnalysisServer()
    @analysisAPI.analysisServer = @analysisServer

  enable: =>
    dartProjectPaths = Utils.getDartProjectPaths()

    @analysisServer.start dartProjectPaths

    @subscriptions.push atom.project.onDidChangePaths @handleProjectPaths

    @subscriptions.push atom.workspace.observeTextEditors (editor) =>
      buc = new BufferUpdateComponent(editor, @analysisAPI)
      editor.onDidDestroy => buc.destroy()

  disable: =>
    @cleanup()

  cleanup: =>
    subscription.dispose() for subscription in @subscriptions
    @subscriptions = []
    @analysisServer?.stop()

  # Event handlers

  handleProjectPaths: (paths) =>
    dartProjectPaths = Utils.getDartProjectPaths()
    # Naively assuming that analysis_server will ensure that the project paths
    # have changed before invalidating everything...
    @analysisServer.setAnalysisRoots dartProjectPaths
