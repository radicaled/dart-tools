{CompositeDisposable} = require 'atom'
_ = require 'lodash'

class AnalysisDecorator
  constructor: (@errors) ->
    @subscriptions = new CompositeDisposable()
    @listen()

  listen: =>
    @subscriptions.add atom.workspace.observeTextEditors @handleEditors
    @subscriptions.add @errors.onChange @handleErrors

  clearMarkers: (editor, problems) =>
    markers = editor.findMarkers
      isDartMarker: true
      isProblem: true

    ms = _.chain(markers)
      .where( (m) => m.isValid() )
      .where( (m) =>
        problem = m.getProperties().problem
        _.any(problems, (p) => _.isEqual(p, problem))
      ).value()
    # console.log "destroying #{ms.length} markers for #{problems.length} problems"
    _.invoke ms, 'destroy'

  decorateEditor: (editor, problems) =>
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
        problem: problem

      editor.decorateMarker marker,
        type: 'highlight',
        class: css

  # Event handlers
  handleErrors: ({file, errors, added, removed}) =>
    for editor in atom.workspace.getTextEditors()
      fullPath = editor.getPath()
      if fullPath == file
        @clearMarkers(editor, removed)
        @decorateEditor(editor, added)
        return


  handleEditors: (editor) =>
    fullPath = editor.getPath()
    problems = @errors.repository[fullPath]
    return unless problems?.length > 0
    @decorateEditor(editor, problems)

  dispose: =>
    @subscriptions.dispose()


module.exports = AnalysisDecorator
