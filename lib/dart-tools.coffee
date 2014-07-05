AnalysisComponent = require './analysis_component'
AnalysisView = require './views/analysis_view'

module.exports =
  # spooky ( ͡° ͜ʖ ͡°)
  analysisComponent: null
  analysisStatusView: null

  activate: (state) ->
    @analysisComponent = new AnalysisComponent()
    @analysisComponent.enable()
    @analysisComponent.analysisServer.on 'analysis', (result) =>
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

          editor.addDecorationForMarker marker,
            type: 'gutter',
            class: css

          editor.addDecorationForMarker marker,
            type: 'highlight',
            class: css

          @analysisComponent.analysisStatusView.addFailure()
          @analysisComponent.analysisView.addProblem(result.desc)

          # atom.workspaceView.appendToBottom new AnalysisView
          # ev.appendToBottom new AnalysisView

  deactivate: ->
    @analysisComponent.disable()

  serialize: ->
