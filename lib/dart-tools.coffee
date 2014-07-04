DartToolsView = require './dart-tools-view'

module.exports =
  # spooky ( ͡° ͜ʖ ͡°)
  dartToolsView: null

  activate: (state) ->
    # @dartToolsView = new DartToolsView(state.dartToolsViewState)
    checkForDart = =>
      pubspec = atom.project.rootDirectory.getFile('pubspec.yaml')
      if pubspec.exists()
        console.log 'Detected Dart Project'

    atom.project.on 'path-changed', checkForDart
    checkForDart() # project was already loaded by the time we're loaded.

  deactivate: ->
    # @dartToolsView.destroy()    

  serialize: ->
    # dartToolsViewState: @dartToolsView.serialize()
