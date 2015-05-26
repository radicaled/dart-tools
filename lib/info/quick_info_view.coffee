{CompositeDisposable} = require 'atom'
rivets = require 'rivets'
Template = require '../templates/template'
_ = require 'lodash'

# Display one (or a few) problems in a panel at the botto of the screen. This is
# used to show the problems for the currently selected line in the editor.
class QuickInfoView
  constructor: ->
    @subscriptions = new CompositeDisposable()
    @editorEvents = new CompositeDisposable()
    @view = new View()
    @listen()

  listen: =>
    @subscriptions.add atom.workspace.observeActivePaneItem @handleActivePane

  observeEditor: (editor) =>
    @editorEvents.dispose()

    @editorEvents.add editor.onDidAddDecoration (decoration) =>
      marker = decoration.getMarker()
      @whenCaretInMarker editor, marker, (marker) =>
        return unless marker.isValid()
        @addMarker(marker)

    @editorEvents.add editor.onDidRemoveDecoration (decoration) =>
      marker = decoration.getMarker()
      @whenCaretInMarker editor, marker, (marker) =>
        @removeMarker(marker)

    @editorEvents.add editor.onDidChangeSelectionRange =>
      range = editor.getSelectedBufferRange()
      markers = @findMarkersOnRow(editor, range.start.row)
      @view.reset()
      @addMarker(marker) for marker in markers
      @view.syncState()

  addMarker: (marker) =>
    @view.addProblem(marker.getProperties().problem)

  removeMarker: (marker) =>
    @view.removeProblem(marker.getProperties().problem)

  # Helpers

  whenCaretInMarker: (editor, marker, callback) =>
    return unless marker.getProperties().isDartMarker

    selectedBufferRange = editor.getSelectedBufferRange()
    markerRange = marker.getBufferRange()
    if markerRange.containsRange(selectedBufferRange)
      callback(marker)

  findMarkersOnRow: (editor, row) =>
    attrs =
      startBufferRow: row
      isDartMarker: true
    markers = editor.findMarkers(attrs)
    _.where markers, (m) -> m.isValid()

  # Events

  handleActivePane: (item) =>
    # There's no way to tell if the item is a text editor or not so just see if
    # there's an active text editor or not.
    editor = atom.workspace.getActiveTextEditor()
    @observeEditor(editor) if editor

  dispose: =>
    @subscriptions.dispose()
    @editorEvents.dispose()

class View
  problems: []

  constructor: ->
    element = Template.get('info/quick_info_view.html')
    @panel = atom.workspace.addBottomPanel(item: element, visible: false)
    @view = rivets.bind(element, {it: this})

    rivets.binders.badge = @badge
    rivets.formatters.formatProblemType = @formatProblemType
    rivets.formatters.formatLocation = @formatLocation
    rivets.formatters.lowerCase = (s) -> if s then s.toLowerCase() else s

  addProblem: (problem) =>
    return if _.any(@problems, (p) => _.isEqual(p, problem))
    @problems.push problem
    @syncState()

  removeProblem: (problem) =>
    @problems = _.where(@problems, (p) => not _.isEqual(p, problem))
    @syncState()

  reset: =>
    @problems = []

  syncState: =>
    if @problems.length is 0 and @panel.isVisible()
      @panel.hide()
    else if @problems.length > 0 and not @panel.isVisible()
      @panel.show()

  formatProblemType: (str) ->
    (str.replace new RegExp('_', 'g'), " ").toLowerCase()

  formatLocation: (location) ->
    "line #{location.startLine}, column #{location.startColumn}"

  badge: (element, problem) ->
    element.classList.remove("badge-info")
    element.classList.remove("badge-warning")
    element.classList.remove("badge-error")
    element.classList.add("badge-#{problem.severity.toLowerCase()}")

module.exports = QuickInfoView
