AutocompleteView = require './views/autocomplete_view'

module.exports =
class AutocompleteComponent

  enable: =>
    atom.workspaceView.eachEditorView (ev) =>
      new AutocompleteView(ev)
