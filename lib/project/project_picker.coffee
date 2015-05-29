_ = require 'lodash'
{SelectListView, $, $$} = require 'atom-space-pen-views'
{match} = require 'fuzzaldrin'
Utils = require '../utils'
path = require 'path'

# Let the user select an item from a list of items
# Most code borrowed from https://github.com/atom/command-palette/blob/master/lib/command-palette-view.coffee
# Items in the form of {item: 'item', displayName: 'Cool Item #1'}
class Picker
  selectFrom: (items) =>
    new Promise (resolve, reject) =>
      view = new PickerView items, resolve, reject
      view.show()

class PickerView extends SelectListView
  initialize: (@selectableItems, @resolve, @reject) ->
    super

    @addClass('picker')

  getFilterKey: -> 'displayName'

  cancelled: ->
    @hide()
    @reject('User cancelled selection')

  toggle: ->
    if @panel?.isVisible()
      @cancel()
    else
      @show()

  show: ->
    @panel ?= atom.workspace.addModalPanel(item: this)
    @panel.show()

    @storeFocusedElement()

    if @previouslyFocusedElement[0] and @previouslyFocusedElement[0] isnt document.body
      @eventElement = @previouslyFocusedElement[0]
    else
      @eventElement = atom.views.getView(atom.workspace)
    @keyBindings = atom.keymaps.findKeyBindings(target: @eventElement)

    @setItems(@selectableItems)

    @focusFilterEditor()

  hide: ->
    @panel?.hide()

  viewForItem: ({item, displayName}) ->
    # Style matched characters in search results
    filterQuery = @getFilterQuery()
    matches = match(displayName, filterQuery)

    $$ ->
      highlighter = (item, matches, offsetIndex) =>
        lastIndex = 0
        matchedChars = [] # Build up a set of matched chars to be more semantic

        for matchIndex in matches
          matchIndex -= offsetIndex
          continue if matchIndex < 0 # If marking up the basename, omit command matches
          unmatched = item.substring(lastIndex, matchIndex)
          if unmatched
            @span matchedChars.join(''), class: 'character-match' if matchedChars.length
            matchedChars = []
            @text unmatched
          matchedChars.push(item[matchIndex])
          lastIndex = matchIndex + 1

        @span matchedChars.join(''), class: 'character-match' if matchedChars.length

        # Remaining characters are plain text
        @text item.substring(lastIndex)

      @li class: 'event', 'data-event-name': item, =>
        @div class: 'pull-right', =>
        @span title: displayName, -> highlighter(displayName, matches, 0)

  confirmed: (item) ->
    @hide()
    @resolve(item.item)

module.exports = Picker
