AnalysisComponent = require './analysis_component'
AnalysisView = require './views/analysis_view'

module.exports =
  # spooky ( ͡° ͜ʖ ͡°)
  analysisComponent: null
  analysisStatusView: null

  activate: (state) ->
    @analysisComponent = new AnalysisComponent()
    @analysisComponent.enable()

    @analysisComponent.on 'dart-tools:refresh', (fullPath) =>
      atom.workspace.emit 'dart-tools:refresh', fullPath
    @analysisComponent.on 'dart-tools:analysis', (result) =>
      atom.workspace.emit 'dart-tools:analysis', result

  deactivate: ->
    @analysisComponent.disable()

  serialize: ->
