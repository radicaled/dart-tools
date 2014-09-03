{$$, SelectListView, Range} = require 'atom'
_ = require 'lodash'

module.exports =
class AutocompleteView extends SelectListView
  SORT_MAP:
    'LOW': 1
    'DEFAULT': 0
    'HIGH': -1

  maxItems: 20

  initialize: (@editorView, @api) ->
    super
    @editor = @editorView.editor

    @addClass('autocomplete popover-list dart-tools-autocomplete')
    @subscribe editorView, 'dart-tools:autocomplete', =>
      @attach()

      path = @editor.getPath()
      pos = @editor.getCursorBufferPosition()
      offset = @editor.buffer.characterIndexForPosition(pos)

      console.log 'autocompleting at', offset

      @showFetchingResults()
      @api.updateFile @editor.getPath(), @editor.getText()
      @api.completion.getSuggestions(path, offset)
        .progress(@handleAutocompleteResult)
        .then(@handleAutocompleteResult)

  # Copied from atom/autocomplete/lib/autocomplete-view.coffee
  attach: ->
    @editor.beginTransaction()

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
    @cancel()

    @insertMatch(item)

  cancelled: ->
    super
    @editor.abortTransaction()

  getFilterKey: ->
    'completion'

  viewForItem: (item) ->
    $$ ->
      @li class: 'two-lines', =>
        @div class: 'primary-line', item.completion
        @div class: 'secondary-line', item.docSummary

  handleAutocompleteResult: (@autocompleteInfo) =>
    results = @autocompleteInfo.params.results
    sortedResults = _.sortBy results, (res) => @SORT_MAP[res.relevance]
    @setItems(sortedResults)
    @showFetchingResults() if @autocompleteInfo.params.isLast == false

  showFetchingResults: =>
    @setLoading('Fetching results...')

  selectItemView: (item) =>
    super

    if match = @getSelectedItem()
      selection = _.first @editor.selectWord()
      return unless selection

      @insertMatch(match)

  selectNextItemView: ->
    super
    false

  selectPreviousItemView: ->
    super
    false

  insertMatch: (item) =>
    {replacementOffset} = @autocompleteInfo.params
    {buffer} = @editor
    {selectionOffset} = item

    pos = @editor.getCursorBufferPosition()

    cursorOffset  = buffer.characterIndexForPosition(pos)
    startPos      = buffer.positionForCharacterIndex(replacementOffset)
    # endPos        = buffer.positionForCharacterIndex(replacementOffset + selectionOffset)
    endPos        = @editor.getCursorBufferPosition()
    range         = new Range(startPos, endPos)

    @editor.setSelectedBufferRange(range)
    @editor.insertText(item.completion)
    
    console.log 'replacementOffset', replacementOffset, 'for item', item
    console.log 'Range is', range
