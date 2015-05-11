_ = require 'lodash'

class AnalysisDecorator
  constructor: (@errors) ->
    @listen()

  listen: =>
    atom.workspace.observeTextEditors @handleEditors
    @errors.onChange @handleErrors

  clearMarkers: (editor) =>
    markers = editor.findMarkers
      isDartMarker: true
      isProblem: true
    _.invoke markers, 'destroy'

  decorateEditor: (editor, problems) =>
    @clearMarkers(editor)
    for problem in problems
      location = problem.location

      category  = problem.severity.toLowerCase()
      line      = location.startLine - 1
      column    = location.startColumn - 1
      css       = "dart-analysis-#{category}"
      marker   = editor.markBufferRange [
        [line, column],
        [line, column + location.length]
      ]

      marker.setProperties
        isDartMarker: true
        isProblem: true

      editor.decorateMarker marker,
        type: 'highlight',
        class: css

  # Event handlers
  handleErrors: ({file, errors}) =>
    for editor in atom.workspace.getTextEditors()
      fullPath = editor.getPath()
      if fullPath == file
        @decorateEditor(editor, errors)
        return


  handleEditors: (editor) =>
    fullPath = editor.getPath()
    problems = @errors.repository[fullPath]
    return unless problems?.length > 0
    @decorateEditor(editor, problems)

module.exports = AnalysisDecorator
