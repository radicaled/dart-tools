{$$, SelectListView} = require 'atom'

module.exports =
class AutocompleteView extends SelectListView
  initialize: (@editorView, @autocompleter) ->
    super
    @editor = @editorView.editor

    @addClass('autocomplete popover-list')
    @subscribe editorView, 'dart-tools:autocomplete', =>
      @attach()
      pos = @editor.getCursorBufferPosition()
      path = @editor.getPath()

      @autocompleter.autocomplete path, pos.row * pos.column

    @subscribe @autocompleter, 'autocomplete', (autocompleteInfo) =>
      results = autocompleteInfo.results
      @setItems(results)

  # Copied from atom/autocomplete/lib/autocomplete-view.coffee
  attach: ->
    @aboveCursor = false
    @originalCursorPosition = @editor.getCursorScreenPosition()

    @editorView.appendToLinesView(this)
    @setPosition()
    @focusFilterEditor()


  # Copied from atom/autocomplete/lib/autocomplete-view.coffee
  setPosition: ->
    {left, top} = @editorView.pixelPositionForScreenPosition(@originalCursorPosition)
    height = @outerHeight()
    width = @outerWidth()
    potentialTop = top + @editorView.lineHeight
    potentialBottom = potentialTop - @editorView.scrollTop() + height
    parentWidth = @parent().width()

    left = parentWidth - width if left + width > parentWidth

    if @aboveCursor or potentialBottom > @editorView.outerHeight()
      @aboveCursor = true
      @css(left: left, top: top - height, bottom: 'inherit')
    else
      @css(left: left, top: potentialTop, bottom: 'inherit')

  getFilterKey: ->
    'completion'
    
  viewForItem: (item) ->
    $$ ->
      @li =>
        @raw item.completion

  selectNextItemView: ->
    super
    false

  selectPreviousItemView: ->
    super
    false
