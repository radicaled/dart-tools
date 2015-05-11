{_}     = require 'lodash'

module.exports =
class QuickIssueModel
  constructor: (@editor) ->

  findMarkersInRange: (range) =>
    attrs =
      containsBufferRange: range
      isDartMarker: true
    markers = @editor.findMarkers(attrs)
    _.where markers, (marker) -> marker.isValid()
