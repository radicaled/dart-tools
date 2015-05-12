rivets = require 'rivets'
Template = require '../templates/template'

class AnalysisToolbar
  constructor: (@errors) ->
    @view = new ToolbarView
    @listen()

  listen: =>
    @errors.onChange @handleErrors

  # Event handlers
  handleErrors: ({file, errors}) =>
    totalErrors = 0
    for k, v of @errors.repository
      totalErrors += v.length
    # TODO: wrong-a-rooni!
    @view.errorCount = totalErrors

class ToolbarView
  shouldShow: true
  hasProblems: =>
    @errorCount > 0 || @warningCount > 0
  errorCount: 0
  warningCount: 0

  constructor: ->
    element = Template.get('analysis/analysis_toolbar.html')
    atom.workspace.addBottomPanel(item: element)
    @view = rivets.bind(element, it: this)

  showProblems: ->
    atom.workspace.open('dart-tools://problem-view')

module.exports = AnalysisToolbar
