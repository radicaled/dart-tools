{Model} = require 'theorist'
{_}     = require 'lodash'

module.exports =
class QuickIssueModel extends Model
  constructor: (@editor) ->

  findMarkersInRange: (range) =>
    attrs =
      containsBufferRange: range
      isDartMarker: true
    markers = @editor.findMarkers(attrs)
    _.where markers, (marker) -> marker.isValid()
