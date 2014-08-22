module.exports =
class AnalysisDecorator
  decoratorMap: {}
  constructor: (@analysisComponent) ->
    @analysisComponent.on 'dart-tools:analysis', (result) =>
      @addDecoratorForAnalysis result
    @analysisComponent.on 'dart-tools:refresh', (fullPath) =>
      @refreshDecoratorsForPath fullPath
    that = this
    atom.workspace.eachEditor (editor) =>
      fullPath = editor.getPath()
      if that.decoratorMap[fullPath]
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

    dec1 = editor.decorateMarker marker,
      type: 'gutter',
      class: css

    dec2 = editor.decorateMarker marker,
      type: 'highlight',
      class: css

    decorators = @decoratorMap[fullpath] ||= []
    decorators.push(dec1)
    decorators.push(dec2)


  refreshDecoratorsForPath: (fullPath) ->
    decorators = @decoratorMap[fullPath] || []
    for dec in decorators
      dec.destroy()
    @decoratorMap[fullPath] = []
