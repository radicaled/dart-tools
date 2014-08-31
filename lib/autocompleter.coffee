{Model} = require 'theorist'

# TODO: migrate to AnalysisAPI
module.exports =
class Autocompleter extends Model
  constructor: (@analysisComponent) ->
    {@analysisServer, @analysisAPI} = @analysisComponent
    @subscribe @analysisServer, "analysis-server:completion.results", (obj) =>
      @emit 'autocomplete', obj.params


  autocomplete: (editor, fullPath, offset)->
    # HACK: update buffer in analysis server before querying
    @analysisAPI.updateFile editor.getPath(), editor.getText()

    @analysisServer.sendMessage
      method: 'completion.getSuggestions'
      params:
        file: fullPath
        offset: offset
