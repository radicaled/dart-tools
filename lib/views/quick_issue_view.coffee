{View} = require 'atom'
QuickIssueModel = require '../quick_issue_model'
Utils = require '../utils'

module.exports =
# This class was meant to attach to the bottom of each EDITOR view,
# but as it turns out there's no API for that yet.
# Therefore, there is one instance of it (like a status bar)
# that updates based on cursor position.
#
# This class only supports 1 cursor
class QuickIssueView extends View
  @content: ->
    @div class: 'tool-panel panel-bottom', =>
      @ul class: 'dart-tools-quick-issue-view', outlet: 'issues'

  initialize: (@editor)->
    @hide()

    # @watchEditor(@editor)

  watchEditor: (editor) =>
    model = new QuickIssueModel(editor)
    @subscribe editor.on 'selection-added selection-screen-range-changed', =>
      @hide()
      @issues.empty()

      selectedBufferRange = editor.getSelectedBufferRange()
      markers = model.findMarkersInRange(selectedBufferRange)

      for marker in markers
        ar = marker.getAttributes().analysisResult
        if ar
          className = 'text-' + ar.severity.toLowerCase()
          @issues.empty()
          @issues.append("<li class='#{className}'>#{ar.message}</li>")
      @show()
