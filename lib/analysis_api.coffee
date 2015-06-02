SearchAPI = require './analysis_api/search_api'
CompletionAPI = require './analysis_api/completion_api'
EditApi = require './analysis_api/edit_api'
{Emitter} = require 'event-kit'

module.exports =
  class AnalysisAPI
    _analysisServer: null

    constructor: (@analysisServer) ->
      @emitter = new Emitter
      Object.defineProperty this, 'analysisServer',
        set: (newValue) => @setServer(newValue)
        get: => @_analysisServer

    setServer: (@_analysisServer) =>
      @search ||= new SearchAPI(this)
      @completion ||= new CompletionAPI(this)
      @edit ||= new EditApi(this)

      # TODO: bit of a hack here
      @_analysisServer.forEachEvent (name, e) =>
        @emitter.emit name, e

    sendMessage: (obj) => @analysisServer?.sendMessage(obj)

    perform: (methodName, params) =>
      @sendMessage
        method: methodName
        params: params

    updateFile: (path, contents) =>
      files = {}
      files[path] =
        type: 'change'
        edits: [
          offset: 0
          length: contents?.length || 0
          replacement: contents
        ]        

      @perform 'analysis.updateContent',
        {files}

    on: (event, callback) =>
      @emitter.on event, callback
