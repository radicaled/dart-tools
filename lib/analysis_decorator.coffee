module.exports =
class AnalysisDecorator
  decoratorMap: {}
  constructor: (@analysisComponent) ->
    @analysisComponent.on 'dart-tools:analysis', (result) =>
      @addDecoratorForAnalysis result
    @analysisComponent.on 'dart-tools:refresh', (fullPath) =>
      @refreshDecoratorsForPath fullPath

  addDecoratorForAnalysis: (result) ->
    loc = result.location
    fullpath = loc.file
    decorators = @decoratorMap[fullpath] ||= []
    for ev in atom.workspaceView.getEditorViews()
      editor = ev.getEditor()

      if editor.getPath() == fullpath
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

        decorators = @decoratorMap[result.fullpath] ||= []
        decorators.push(dec1)
        decorators.push(dec2)

        return

  refreshDecoratorsForPath: (fullPath) ->
    decorators = @decoratorMap[fullPath] || []
    for dec in decorators
      dec.destroy()
    @decoratorMap[fullPath] = []
