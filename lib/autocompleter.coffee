{Model} = require 'theorist'

# TODO: migrate to AnalysisAPI
module.exports =
class Autocompleter extends Model
  constructor: (@analysisComponent) ->
    {@analysisServer} = @analysisComponent
    @subscribe @analysisServer, "analysis-server:completion.results", (obj) =>
      @emit 'autocomplete', obj.params


  autocomplete: (fullPath, offset)->
    @analysisServer.sendMessage
      method: 'completion.getSuggestions'
      params:
        file: fullPath
        offset: offset
