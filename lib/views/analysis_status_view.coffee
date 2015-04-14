{View} = require 'atom-space-pen-views'
{_} = require 'lodash'

module.exports =
class AnalysisStatusView extends View
  Object.defineProperty @::, 'analysisCount', get: -> @items.length
  items: []

  @content: ->
    @div class: 'inline-block', =>
      @a href: '#', click: 'showAnalysis', =>
        @span class: 'dart-tools-status icon'
        @span class: 'dart-tools-status-text'

  initialize: (@statusBar) =>
    @subscribe atom.workspace, 'dart-tools:analysis', (result) =>
      @items.push(result)
      @updateState()

    @subscribe atom.workspace, 'dart-tools:refresh', (fullPath) =>
      _.remove @items, (item) => item.location.file == fullPath
      @updateState()

  attach: ->
    @updateState()
    atom.workspaceView.statusBar?.appendLeft(this)

  updateState: ->
    length = @items.length
    className = if length > 0 then 'icon-x' else 'icon-check'
    statusText = if length > 0 then "#{length} issues" else 'No issues'

    @find('.dart-tools-status')
      .removeClass('icon-x icon-check')
      .addClass(className)
    @find('.dart-tools-status-text').text(statusText)


  showAnalysis: (e) ->
    atom.workspaceView.trigger('dart-tools:problems:show')
    e.preventDefault()
