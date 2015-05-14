{CompositeDisposable} = require 'atom'
rivets = require 'rivets'
Template = require '../templates/template'
_ = require 'lodash'

class QuickInfoView
  constructor: ->
    @editorEvents = new CompositeDisposable()
    @view = new View()
    @listen()

  listen: =>
    atom.workspace.observeActivePaneItem @handleActivePane

  observeEditor: (editor) =>
    @editorEvents.dispose()

    @editorEvents.add editor.onDidAddDecoration (decoration) =>
      marker = decoration.getMarker()
      @withValidMarker editor, marker, (marker) =>
        @addMarker(marker)

    @editorEvents.add editor.onDidRemoveDecoration (decoration) =>
      marker = decoration.getMarker()
      @withValidMarker editor, marker, (marker) =>
        @removeMarker(marker)

    @editorEvents.add editor.onDidChangeSelectionRange =>
      selectedBufferRange = editor.getSelectedBufferRange()
      markers = @findMarkersInRange(editor, selectedBufferRange)

      @view.reset()
      @addMarker(marker) for marker in markers

  addMarker: (marker) =>
    @view.addProblem(marker.getProperties().problem)

  removeMarker: (marker) =>
    @view.removeProblem(marker.getProperties().problem)

  # Helpers

  withValidMarker: (editor, marker, callback) =>
    return unless marker.getProperties().isDartMarker
    return unless marker.isValid()

    selectedBufferRange = editor.getSelectedBufferRange()
    markerRange = marker.getBufferRange()
    if markerRange.containsRange(selectedBufferRange)
      callback(marker)

  findMarkersInRange: (editor, range) =>
    attrs =
      containsBufferRange: range
      isDartMarker: true
    markers = editor.findMarkers(attrs)
    _.where markers, (m) -> m.isValid()

  # Events

  handleActivePane: (item) =>
    # There's no way to tell if the item is a text editor or not
    # so just see if there's an active text editor or not
    editor = atom.workspace.getActiveTextEditor()
    @observeEditor(editor) if editor

class View
  shouldShow: => @problems.length > 0
  problems: []

  constructor: ->
    element = Template.get('info/quick_info_view.html')
    atom.workspace.addBottomPanel(item: element)
    @view = rivets.bind(element, {it: this})

    rivets.formatters.formattedProblem = @formattedProblem
    rivets.formatters.lowerCase = (s) -> if s then s.toLowerCase() else s

  addProblem: (problem) =>
    return if _.any(@problems, (p) => _.isEqual(p, problem))
    @problems.push problem

  removeProblem: (problem) =>
    @problems = _.where(@problems, (p) => !_.isEqual(p, problem))

  reset: =>
    @problems = []

  formattedProblem: (problem) ->
    problem.message

module.exports = QuickInfoView
