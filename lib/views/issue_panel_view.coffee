{View} = require 'atom'

module.exports =
class IssuePanelView extends View
  @content: ->
    @div class: 'tool-panel panel-bottom padded', =>
      @div 'Hello, World'

  monitorIt: ->
    atom.workspaceView.eachEditorView (ev) =>
      ev.on 'cursor:moved', =>
        @hide()
        editor = ev.getEditor()
        markers = editor.getMarkers()
        for marker in markers
          if marker.getAttributes().isDartMarker
            range = marker.getBufferRange()
            cursor = editor.getCursor()
            cursorPos = cursor.getBufferPosition()

            if range.containsPoint(cursorPos)
              @show()
