{Model} = require 'theorist'

module.exports =
class Autocompleter extends Model
  constructor: (@analysisComponent) ->
    {@analysisServer} = @analysisComponent
    @subscribe @analysisServer, "analysis-server:completion.results", (obj) =>
      console.log 'Received completion: ', obj
      @emit 'autocomplete', obj.params


  autocomplete: (fullPath, offset)->
    @analysisServer.sendMessage
      method: 'completion.getSuggestions'
      params:
        file: fullPath
        offset: offset
