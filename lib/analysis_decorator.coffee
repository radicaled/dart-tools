module.exports =
class AnalysisDecorator
  decoratorMap: {}
  constructor: (@analysisComponent) ->
    @analysisComponent.on 'dart-tools:analysis', (result) =>
      @addDecoratorForAnalysis result
    @analysisComponent.on 'dart-tools:refresh', (fullPath) =>
      @refreshDecoratorsForPath fullPath

  addDecoratorForAnalysis: (result) ->
    decorators = @decoratorMap[result.fullpath] ||= []
    for ev in atom.workspaceView.getEditorViews()
      editor = ev.getEditor()

      if editor.getPath() == result.fullpath
        category = result.category.toLowerCase()
        line = result.line - 1;
        col  = result.column - 1
        css = "dart-analysis-#{category}"
        marker = editor.markBufferRange [
          [line, col],
          [line, col + result.length]
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
