AnalysisComponent = require './analysis_component'
AnalysisView = require './views/analysis_view'

module.exports =
  # spooky ( ͡° ͜ʖ ͡°)
  analysisComponent: null
  analysisStatusView: null

  activate: (state) ->
    @analysisComponent = new AnalysisComponent()
    @analysisComponent.enable()

    return unless @analysisComponent.isDartProject()

    @analysisComponent.analysisServer.on 'refresh', (fullPath) =>
      atom.workspace.emit 'dart-tools:refresh', fullPath
    @analysisComponent.analysisServer.on 'analysis', (result) =>
      atom.workspace.emit 'dart-tools:analysis', result

      console.log 'Analyzed!', result
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

  deactivate: ->
    @analysisComponent.disable()

  serialize: ->
