DartToolsView = require './dart-tools-view'

module.exports =
  dartToolsView: null

  activate: (state) ->
    @dartToolsView = new DartToolsView(state.dartToolsViewState)

  deactivate: ->
    @dartToolsView.destroy()

  serialize: ->
    dartToolsViewState: @dartToolsView.serialize()
