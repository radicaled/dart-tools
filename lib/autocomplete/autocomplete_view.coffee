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

      selection = _.first @editor.selectWord()
      @adjustSelectionForDot(selection)
      @filterEditorView.setText(selection.getText())

      path = @editor.getPath()
      pos = @editor.getCursorBufferPosition()
      offset = @editor.buffer.characterIndexForPosition(pos)

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
    {replacementOffset} = @autocompleteInfo.params
    {buffer} = @editor
    {selectionOffset} = item

    @cancel()

    startPos = buffer.positionForCharacterIndex(replacementOffset)
    endPos   = buffer.positionForCharacterIndex(replacementOffset + selectionOffset)
    range    = new Range(startPos, endPos)

    # TODO: replace when analysis_server is fixed (?)
    # Or I might be using it wrong. Whatever.
    # if replacementOffset were accurate, we'd use the following:
    # @editor.setTextInBufferRange range, item.completion
    # instead, we make a gamble that all completions are word-based:
    selection = _.first @editor.selectWord()
    @adjustSelectionForDot(selection)
    selection?.insertText(item.completion)

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

      @adjustSelectionForDot(selection)

      selection.insertText(match.completion)
      @editor.selectWord()

  selectNextItemView: ->
    super
    false

  selectPreviousItemView: ->
    super
    false

  adjustSelectionForDot: (selection) ->
    if selection.getText()[0] == '.'
      rng = selection.getBufferRange()
      rng.start = rng.start.translate({ column: 1 })
      selection.setBufferRange(rng)
