AutocompleteView = require './autocomplete_view'
Utils = require '../utils'

module.exports =
class AutocompleteComponent
  constructor: (@analysisComponent) ->

  enable: =>
    atom.workspaceView.eachEditorView (ev) =>
      if Utils.isDartFile(ev.getEditor().getPath())
        new AutocompleteView(ev, @analysisComponent.analysisAPI)
