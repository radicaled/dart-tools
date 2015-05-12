{Emitter} = require 'event-kit'

class ErrorRepository

  constructor: (@analysisApi) ->
    @emitter = new Emitter()
    @repository = {}

    @listen()

  listen: =>
    @analysisApi.on "analysis.errors", @handleErrors

  forEachFileWithError: (callback) =>
    for k, v of @repository
      callback(k, v) if v.length > 0
        
  handleErrors: (data) =>
    file = data.params.file
    errors = data.params.errors
    @repository[file] = errors

    @emitter.emit 'change',
      file: file
      errors: errors

  onChange: (callback) =>
    @emitter.on 'change', callback

module.exports = ErrorRepository
