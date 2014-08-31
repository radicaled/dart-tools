SearchAPI = require './analysis_api/search_api'

module.exports =
  class AnalysisAPI
    _analysisServer: null

    constructor: (@analysisServer) ->
      Object.defineProperty this, 'analysisServer',
        set: (newValue) => @setServer(newValue)
        get: => @_analysisServer

    setServer: (@_analysisServer) =>
      @search ||= new SearchAPI(this)

    sendMessage: (obj) => @analysisServer?.sendMessage(obj)

    perform: (methodName, params) =>
      @sendMessage
        method: methodName
        params: params

    updateFile: (path, contents) =>
      files = {}
      files[path] =
        type: 'add'
        content: contents

      @perform 'analysis.updateContent',
        {files}
