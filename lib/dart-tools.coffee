DartToolsView = require './dart-tools-view'
AnalysisComponent = require './analysis_component'

module.exports =
  # spooky ( ͡° ͜ʖ ͡°)
  dartToolsView: null
  watcher: null
  analysisComponent: null

  activate: (state) ->
    @analysisComponent = new AnalysisComponent()
    @analysisComponent.enable()
    @analysisComponent.analysisServer.on 'analysis', (result) =>
      console.log 'Analyzed!', result


  deactivate: ->
    @analysisComponent.disable()

  serialize: ->
