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
      for ev in atom.workspaceView.getEditorViews()
        editor = ev.getEditor()

        if editor.getPath() == result.fullpath
          category = result.category.toLowerCase()          
          ev.gutter.addClassToLine result.line - 1, "dart-analysis-#{category}"



  deactivate: ->
    @analysisComponent.disable()

  serialize: ->
