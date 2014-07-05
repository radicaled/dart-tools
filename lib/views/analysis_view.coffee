{View} = require 'atom'

module.exports =
class AnalysisView extends View
  @content: ->
    @div class: 'tool-panel panel-bottom padded', =>
      'No Errors Detected'

  initialize: =>
    @subscribe atom.workspaceView, 'dart-tools:problems:show', =>
      @attach()

  attach: ->
    atom.workspaceView.appendToBottom(this)

  addProblem: (text) ->
    row = new ErrorRow()
    row.text(text)
    this.append(row)


class ErrorRow extends View
  @content: ->
    @div class: 'text-warning'
