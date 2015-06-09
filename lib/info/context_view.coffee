{CompositeDisposable, Point} = require 'atom'
rivets = require 'rivets'
Template = require '../templates/template'
Utils = require '../utils'
_ = require 'lodash'


# TODO: probably not the best name for this class.
# Shows quick information / documentation about the element at the current caret
class ContextView
  constructor: (@analysisApi) ->
    @subscriptions = new CompositeDisposable()
    @editorEvents = new CompositeDisposable()
    @view = new View()
    @listen()

  listen: =>
    @subscriptions.add atom.commands.add 'atom-text-editor','dart-tools:show-information', @handleShowInformation

  # Event Handlers

  handleShowInformation: =>
    editor = atom.workspace.getActiveTextEditor()
    return unless Utils.isCompatible(editor)
    path = editor.getPath()
    bufferPosition = editor.getCursorBufferPosition()
    offset = editor.buffer.characterIndexForPosition(bufferPosition)
    @analysisApi.analysis.getHover(path, offset).then(
      (response) =>
        hovers = response.result.hovers
        title = ''
        output = ''

        return unless hovers.length > 0

        for hover in hovers
          offset = hover.offset
          length = hover.length
          containingLibraryPath = hover.containingLibraryPath
          containingLibraryName = hover.containingLibraryName
          containingClassDescription = hover.containingClassDescription
          dartdoc = hover.dartdoc
          elementDescription = hover.elementDescription
          elementKind = hover.elementKind
          parameter = hover.parameter
          propagatedType = hover.propagatedType
          staticType = hover.staticType


          title  = "(#{elementKind}) #{elementDescription}"
          output = dartdoc?.replace(/\n/g, '<br />') or 'No documentation'
          @view.highlight(editor, offset, length)

        @view.title = title
        @view.output = output
        @view.show()

    )


  dispose: =>
    @subscriptions.dispose()
    @view.dispose()

class View
  title: 'Details'
  output: 'None'

  constructor: ->
    element = Template.get('info/context_view.html')
    @panel = atom.workspace.addModalPanel(item: element, visible: false)
    @view = rivets.bind(element, {it: this})
    atom.commands.add 'atom-workspace', 'core:cancel', =>
      @hide()

  highlight: (editor, offset, length) =>
    @marker?.destroy()
    start = editor.buffer.positionForCharacterIndex(offset)
    finish = new Point(start.row, start.column + length)
    @marker = editor.markBufferRange [start, finish]
    editor.decorateMarker @marker,
      type: 'highlight',
      class: 'context-view-highlight'

  show: =>
    @panel.show()

  hide: =>
    @panel.hide()
    @marker?.destroy()

  dispose: =>
    @panel.destroy()

module.exports = ContextView
