{$, $$, View} = require 'atom'
_ = require 'lodash'
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
    editor.onDidAddDecoration (decoration) =>
      selectedBufferRange = editor.getSelectedBufferRange()
      marker = decoration.getMarker()
      markerRange = marker.getBufferRange()
      if markerRange.containsRange(selectedBufferRange)
        @showMarker(marker)
        @show()

    @subscribe editor.on 'selection-added selection-screen-range-changed', =>
      @hide()
      @issues.empty()

      selectedBufferRange = editor.getSelectedBufferRange()
      markers = model.findMarkersInRange(selectedBufferRange)

      for marker in markers
        @showMarker(marker)

      @show()

  showMarker: (marker) =>
    ar = marker.getAttributes().analysisResult
    # We can't detect when new markers are added, only decorations
    # Since 2 decorations can point to the same marker, let's just filter
    # by analysisResult message by now. Duplicate messages aren't helpful
    # anyway.
    knownMarkers = _.map @issues.find('li'), (view) ->
      $(view).data('marker')    
    if ar && !_.contains(knownMarkers, marker)
      view = @viewForAnalysisResult(ar)
      view.data('marker', marker)
      @issues.append(view)
      # Remove this marker from our list if we're still on top of it
      # and its been destroyed. Automated tools may do something
      # to trigger this.
      marker.onDidDestroy =>
        view.remove()

  viewForAnalysisResult: (ar) =>
    $$ ->
      @li class: 'text-' + ar.severity.toLowerCase(), =>
        @text ar.message
