module.exports =
class AnalysisDecorator
  constructor: (@analysisComponent) ->
      @analysisComponent.on 'dart-tools:analysis', (result) ->
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

            editor.decorateMarker marker,
              type: 'gutter',
              class: css

            editor.decorateMarker marker,
              type: 'highlight',
              class: css
