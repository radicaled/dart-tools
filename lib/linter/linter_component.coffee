{Range, Point} = require 'atom'
_ = require 'lodash'

class LinterComponent
  constructor: (@linter, @errorRepository) ->
    LinterComponent.warn() unless @linter
    @setup() if @linter

  @warn: ->
    msg = '[dart-tools] The linter package is required to provide details
    about errors and warnings.'
    atom.notifications.addWarning msg

  check: => LinterComponent.warn(@linter)
  setup: =>
    # @linter.addLinter(linterConfig)

    updateErrors = =>
      messages = []

      @errorRepository.forEachFileWithError (file, errors) =>
        for error in errors
          location = error.location
          line      = location.startLine - 1
          column    = location.startColumn - 1
          range = new Range(
            new Point(line, column),
            new Point(line, column + location.length)
          )

          messages.push
            type: _.capitalize(error.severity.toLowerCase())
            text: error.message
            filePath: file
            range: range

      @linter.deleteMessages(linterConfig)
      @linter.setMessages linterConfig, messages

    @errorRepository.onChange _.debounce(updateErrors, 250, maxWait: 1000)

linterConfig =
  grammarScopes: ['source.dart']
  scope: 'project'
  lintOnFly: false
  # lint: ->
  # The linting, it does nothing!

module.exports = LinterComponent
