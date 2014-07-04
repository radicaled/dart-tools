{View} = require 'atom'

module.exports =
class DartToolsView extends View
  @content: ->
    @div class: 'dart-tools overlay from-top', =>
      @div "The DartTools package is Alive! It's ALIVE!", class: "message"

  initialize: (serializeState) ->
    atom.workspaceView.command "dart-tools:toggle", => @toggle()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @detach()

  toggle: ->
    console.log "DartToolsView was toggled!"
    if @hasParent()
      @detach()
    else
      atom.workspaceView.append(this)
