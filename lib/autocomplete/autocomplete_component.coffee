AutocompleteView = require './autocomplete_view'

module.exports =
class AutocompleteComponent
  constructor: (@analysisComponent) ->

  enable: =>
    atom.workspaceView.eachEditorView (ev) =>
      new AutocompleteView(ev, @analysisComponent.analysisAPI)
