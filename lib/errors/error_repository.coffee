{Emitter} = require 'event-kit'
_         = require 'lodash'

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

  findAddedErrors: (oldErrors, newErrors) =>
    return newErrors if oldErrors.length is 0
    _.where newErrors, (ne) =>
      not _.any oldErrors, (oe) => _.isEqual(ne, oe)

  findRemovedErrors: (oldErrors, newErrors) =>
    return oldErrors if newErrors.length is 0
    _.where oldErrors, (oe) =>
      not _.any newErrors, (ne) => _.isEqual(ne, oe)

  handleErrors: (data) =>
    file = data.params.file
    errors = data.params.errors
    oldErrors = @repository[file] or []
    @repository[file] = errors

    addedErrors = @findAddedErrors(oldErrors, errors)
    removedErrors = @findRemovedErrors(oldErrors, errors)

    @emitter.emit 'change',
      file: file
      errors: errors
      added: addedErrors
      removed: removedErrors

    return

  onChange: (callback) =>
    @emitter.on 'change', callback

module.exports = ErrorRepository
