{CompositeDisposable} = require 'atom'
GotoDeclaration = require './goto_declaration'

class NavigationComponent
  constructor: (@analysisApi) ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add @analysisApi.on 'analysis.navigation', @handleNavigation

    @analysisApi.analysis.setSubscriptions

    atom.commands.add 'atom-workspace', 'symbols-view:go-to-declaration', =>
      goto = new GotoDeclaration @analysisApi
      goto.displayProjectSymbols()


  handleNavigation: (event) =>



  disable: =>
    @dispose()

  dispose: =>
    @subscriptions.dispose()

module.exports = NavigationComponent
