{Point} = require 'atom'
{View} = require 'atom-space-pen-views'
{_} = require 'lodash'

module.exports =
class AnalysisView extends View
  items: []

  @content: ->
    @div class: 'tool-panel panel-bottom padded', =>
      @div class: 'pull-right', =>
        @a href: '#', class: 'icon icon-x', rel: 'dismiss', click: 'dismiss'
      @div class: 'dart-tools-analysis-tool-panel'


  initialize: =>
    atom.commands.add 'atom-workspace', 'dart-tools:toggle-analysis-view', =>
      @toggle()

    atom.commands.add 'atom-workspace', 'dart-tools:problems:show', =>
      @show()

    atom.commands.add 'atom-workspace', 'dart-tools:analysis', (result) =>
      @items.push(result)
      @updateState()

    atom.commands.add 'atom-workspace', 'dart-tools:refresh', (fullPath) =>
      _.remove @items, (item) => item.location.file == fullPath
      @updateState()
    this

  attach: ->
    @updateState()
    @hide()
    atom.workspaceView.prependToBottom(this)

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

  initialize: ({@analysisResult}) ->

  @analysisRow: (analysisResult) ->
    className = 'text-' + analysisResult.severity.toLowerCase()
    @div class: className, =>
      @a click: 'gotoAnalysis', =>
        @text @analysisText(analysisResult)

  @analysisText: (analysisResult) ->
     loc = analysisResult.location
     "#{loc.file}:#{loc.startLine}: #{analysisResult.message}"

  gotoAnalysis: =>
    loc = @analysisResult.location
    point = new Point(loc.startLine - 1, loc.startColumn - 1)

    promise = atom.workspace.open loc.file

    promise.then (editor) ->
      editor.setCursorBufferPosition(point)
      editor.scrollToBufferPosition(point)
      editor.emit 'dart-tools:refresh-quick-issue-view'

class LennyRow extends View
  @content: ->
    @div class: 'lenny', "( ͡° ͜ʖ ͡°) doesn't see any problems. Relax, man."
