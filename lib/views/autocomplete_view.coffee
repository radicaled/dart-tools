{$$, SelectListView, Range} = require 'atom'
_ = require 'lodash'

module.exports =
class AutocompleteView extends SelectListView
  SORT_MAP:
    'LOW': 1
    'DEFAULT': 0
    'HIGH': -1

  maxItems: 20

  initialize: (@editorView, @autocompleter) ->
    super
    @editor = @editorView.editor

    @addClass('autocomplete popover-list')
    @subscribe editorView, 'dart-tools:autocomplete', =>
      @attach()
      path = @editor.getPath()
      pos = @editor.getCursorBufferPosition()
      offset = @editor.buffer.characterIndexForPosition(pos)

      @autocompleter.autocomplete path, offset

    @subscribe @autocompleter, 'autocomplete', (@autocompleteInfo) =>
      results = @autocompleteInfo.results
      sortedResults = _.sortBy results, (res) => @SORT_MAP[res.relevance]
      @setItems(sortedResults)

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

  confirmed: (item) ->
    {replacementOffset} = @autocompleteInfo
    {buffer} = @editor
    {selectionOffset} = item

    startPos = buffer.positionForCharacterIndex(replacementOffset)
    endPos   = buffer.positionForCharacterIndex(replacementOffset + selectionOffset)
    range    = new Range(startPos, endPos)

    # TODO: replace when analysis_server is fixed (?)
    # Or I might be using it wrong. Whatever.
    # if replacementOffset were accurate, we'd use the following:
    # @editor.setTextInBufferRange range, item.completion
    # instead, we make a gamble that all completions are word-based:
    selection = _.first @editor.selectWord()
    selection?.insertText(item.completion)
    @cancel()

  getFilterKey: ->
    'completion'

  viewForItem: (item) ->
    $$ ->
      @li class: 'two-lines', =>
        @div class: 'primary-line', item.completion
        @div class: 'secondary-line', item.docSummary

  selectNextItemView: ->
    super
    false

  selectPreviousItemView: ->
    super
    false
