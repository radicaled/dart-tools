{View} = require 'atom'
{_} = require 'lodash'

module.exports =
class AnalysisView extends View
  items: []

  @content: ->
    @div class: 'inline-block', =>
      @div class: 'tool-panel panel-bottom padded', =>
        @div class: 'pull-right', =>
          @a href: '#', class: 'icon icon-x', rel: 'dismiss', click: 'dismiss'
        @div class: 'dart-tools-analysis-tool-panel'


  initialize: =>
    @subscribe atom.workspaceView, 'dart-tools:problems:show', =>
      @show()

    @subscribe atom.workspace, 'dart-tools:analysis', (result) =>
      @items.push(result)
      @updateState()

    @subscribe atom.workspace, 'dart-tools:refresh', (fullPath) =>
      _.remove @items, (item) => item.location.file == fullPath
      @updateState()
    this

  attach: ->
    @updateState()
    @hide()
    atom.workspaceView.appendToBottom(this)

  updateState: ->
    panel = @find('.dart-tools-analysis-tool-panel')
    panel.html('')
    if @items.length == 0
      panel.append(new LennyRow())
    else
      panel.append(new AnalysisResultRow(analysisResult: item)) for item in @items


  dismiss: (e) ->
    @hide()

class AnalysisResultRow extends View
  @content: (params) ->
    @analysisRow(params.analysisResult)

  @analysisRow: (analysisResult) ->
    className = 'text-' + analysisResult.severity.toLowerCase()
    @div class: className, @analysisText(analysisResult)

  @analysisText: (analysisResult) ->
     loc = analysisResult.location
     "#{loc.file}:#{loc.startLine}: #{analysisResult.message}"

class LennyRow extends View
  @content: ->
    @div class: 'lenny', "( ͡° ͜ʖ ͡°) doesn't see any problems. Relax, man."
