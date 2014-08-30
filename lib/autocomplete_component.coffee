AutocompleteView = require './views/autocomplete_view'
Autocompleter = require './autocompleter'

module.exports =
class AutocompleteComponent
  constructor: (@analysisComponent) ->

  enable: =>
    autocompleter = new Autocompleter(@analysisComponent)
    atom.workspaceView.eachEditorView (ev) =>
      new AutocompleteView(ev, autocompleter)
