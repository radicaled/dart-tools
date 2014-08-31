AutocompleteView = require './views/autocomplete_view'
Autocompleter = require './autocompleter'

module.exports =
class AutocompleteComponent
  constructor: (@analysisComponent) ->

  enable: =>
    atom.workspaceView.eachEditorView (ev) =>
      new AutocompleteView(ev, @analysisComponent.analysisAPI)
