{View} = require 'atom'

module.exports =
class QuickIssueView extends View
  @content: ->
    @div class: 'tool-panel panel-bottom', =>
      @ul class: 'dart-tools-quick-issue-view', outlet: 'issues'

  initialize: ->
    @hide()
    @monitorCursor()

  monitorCursor: ->
    atom.workspaceView.eachEditorView (ev) =>
      ev.on 'cursor:moved', =>
        @hide()
        @issues.empty()
        editor = ev.getEditor()
        markers = editor.getMarkers()
        for marker in markers
          if marker.getAttributes().isDartMarker
            range = marker.getBufferRange()
            cursor = editor.getCursor()
            cursorPos = cursor.getBufferPosition()

            if range.containsPoint(cursorPos)
              ar = marker.getAttributes().analysisResult
              className = 'text-' + ar.severity.toLowerCase()
              @issues.empty()
              @issues.append("<li class='#{className}'>#{ar.message}</li>")
              @show()
