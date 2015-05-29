_ = require 'lodash'
{SelectListView, $, $$} = require 'atom-space-pen-views'
{match} = require 'fuzzaldrin'
Utils = require '../utils'
path = require 'path'
# Let the user select a project for project-scoped commands (Pub, etc)
# Most code borrowed from https://github.com/atom/command-palette/blob/master/lib/command-palette-view.coffee
class ProjectPicker
  selectProject: =>
    new Promise (resolve, reject) =>
      view = new ProjectPickerView resolve, reject
      view.show()

class ProjectPickerView extends SelectListView
  initialize: (@resolve, @reject) ->
    super

    @addClass('project-picker')

  cancelled: ->
    @hide()
    @reject('User cancelled project selection')

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

    projects = (project for project in Utils.getDartProjectPaths()).map (p) -> p
    @setItems(projects)

    @focusFilterEditor()

  hide: ->
    @panel?.hide()

  viewForItem: (project) ->
    displayName = path.basename(project)
    # Style matched characters in search results
    filterQuery = @getFilterQuery()
    matches = match(displayName, filterQuery)
    # friendlyName = path.basename(project)

    $$ ->
      highlighter = (project, matches, offsetIndex) =>
        lastIndex = 0
        matchedChars = [] # Build up a set of matched chars to be more semantic

        for matchIndex in matches
          matchIndex -= offsetIndex
          continue if matchIndex < 0 # If marking up the basename, omit command matches
          unmatched = project.substring(lastIndex, matchIndex)
          if unmatched
            @span matchedChars.join(''), class: 'character-match' if matchedChars.length
            matchedChars = []
            @text unmatched
          matchedChars.push(project[matchIndex])
          lastIndex = matchIndex + 1

        @span matchedChars.join(''), class: 'character-match' if matchedChars.length

        # Remaining characters are plain text
        @text project.substring(lastIndex)

      @li class: 'event', 'data-event-name': project, =>
        @div class: 'pull-right', =>
        @span title: displayName, -> highlighter(displayName, matches, 0)

  confirmed: (projectPath) ->
    @hide()
    @resolve(projectPath)

module.exports = ProjectPicker
