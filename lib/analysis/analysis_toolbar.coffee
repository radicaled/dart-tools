_ = require 'lodash'
rivets = require 'rivets'
Template = require '../templates/template'

# A class to display the errors summary for the workspace
# ("Dart Tools 91 issues"). Shown above the status line.
class AnalysisToolbar
  @infoTypes = [
    'HINT',
    'TODO',
    'LINT'
  ]

  @warningTypes = [
    'STATIC_WARNING',
    'STATIC_TYPE_WARNING'
  ]

  constructor: (@errors) ->
    @view = new ToolbarView
    @listen()

  listen: =>
    @errors.onChange @handleErrors

  # Event handlers
  handleErrors: ({file, errors}) =>
    totalProblems = 0
    totalWarnings = 0
    totalErrors   = 0
    totalInfo     = 0
    for path, errors of @errors.repository
      totalProblems += errors.length

      totalInfo     += _.sum errors, (p) =>
        if AnalysisToolbar.infoTypes.indexOf(p.type) != -1 then 1 else 0

      totalWarnings += _.sum errors, (p) =>
        if AnalysisToolbar.warningTypes.indexOf(p.type) != -1 then 1 else 0

      totalErrors   += _.sum errors, (p) =>
        isInfo    = AnalysisToolbar.infoTypes.indexOf(p.type) != -1
        isWarning = AnalysisToolbar.warningTypes.indexOf(p.type) != -1

        if !isInfo && !isWarning then 1 else 0

    @view.problemCount  = totalProblems
    @view.infoCount     = totalInfo
    @view.warningCount  = totalWarnings
    @view.errorCount    = totalErrors


class ToolbarView
  shouldShow: true
  problemCount: 0
  infoCount: 0
  errorCount: 0
  warningCount: 0

  constructor: ->
    element = Template.get('analysis/analysis_toolbar.html')
    atom.workspace.addBottomPanel(item: element)
    @view = rivets.bind(element, it: this)

  showProblems: ->
    atom.workspace.open('dart-tools://problem-view')

module.exports = AnalysisToolbar
