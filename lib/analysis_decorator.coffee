module.exports =
class AnalysisDecorator
  constructor: (@analysisComponent) ->
    @analysisComponent.on 'dart-tools:analysis', (result) =>
      @addDecoratorForAnalysis result
    @analysisComponent.on 'dart-tools:refresh', (fullPath) =>
      @refreshDecoratorsForPath fullPath
    that = this

    atom.workspace.eachEditor (editor) =>
      fullPath = editor.getPath()
      results = that.analysisComponent.analysisResultsMap[fullPath] || []
      for result in results
        if fullPath == result.location.file
          that.decorateEditor(result, editor)

  addDecoratorForAnalysis: (result) ->
    for editor in atom.workspace.getEditors()
      if editor.getPath() == result.location.file
        @decorateEditor(result, editor)
        return

  decorateEditor: (result, editor) ->
    loc = result.location
    fullpath = loc.file

    category = result.severity.toLowerCase()
    line = loc.startLine   - 1;
    col  = loc.startColumn - 1
    css = "dart-analysis-#{category}"
    marker = editor.markBufferRange [
      [line, col],
      [line, col + loc.length]
    ]

    @noteMarker(marker)

    editor.decorateMarker marker,
      type: 'gutter',
      class: css

    editor.decorateMarker marker,
      type: 'highlight',
      class: css

  refreshDecoratorsForPath: (fullPath) ->
    for editor in atom.workspace.getEditors()
      if editor.getPath() == fullPath
        for marker in editor.getMarkers()
          marker.destroy() if @isDartMarker(marker)
        return

  noteMarker: (marker) ->
    marker.setAttributes
      isDartMarker: true

  isDartMarker: (marker) ->
    marker.getAttributes().isDartMarker == true
