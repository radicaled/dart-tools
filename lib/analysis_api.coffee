module.exports =
  class AnalysisAPI
    analysisServer: null

    constructor: (@analysisServer) ->

    sendMessage: (obj) => @analysisServer.sendMessage(obj)

    perform: (methodName, params) =>
      @sendMessage
        method: methodName
        {params}

    updateFile: (path, contents) =>
      files = {}
      files[path] =
        type: 'add'
        content: contents

      @perform 'analysis.updateContent',
        {files}
