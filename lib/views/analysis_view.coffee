{View} = require 'atom'
React = require 'react-atom-fork'
{_} = require 'lodash'
{a, div, span} = require 'reactionary-atom-fork'

module.exports =
class AnalysisView extends View
  items: []

  @content: ->
    @div class: 'inline-block'

  initialize: =>
    @subscribe atom.workspaceView, 'dart-tools:problems:show', =>
      @component?.show()

    @subscribe atom.workspaceView, 'dart-tools:problems:hide', =>
      @component?.hide()

    @subscribe atom.workspace, 'dart-tools:analysis', (result) =>
      @items.push(result)
      @updateState()
      return null

    @subscribe atom.workspace, 'dart-tools:refresh', (fullPath) =>
      _.remove @items, (item) => item.fullpath == fullPath
      @updateState()
      return null
    this

  attach: ->
    atom.workspaceView.appendToBottom(this)

  afterAttach: ->
    @component = React.renderComponent (AnalysisPanel {items: @items }), @element

  updateState: ->
    @component.setState({ items: @items })

AnalysisPanel = React.createClass
  show: ->
    @setProps(visible: true)
  hide: ->
    @setProps(visible: false)

  dismiss: (e) ->
    atom.workspaceView.trigger 'dart-tools:problems:hide'
    e.preventDefault()
    return false

  render: ->
    display = 'none' unless @props.visible

    if @props.items.length == 0
      return div className: 'tool-panel panel-bottom padded', style: {display},
        div className: 'pull-right',
          a href: '#', className: 'icon icon-x', rel: 'dismiss', onClick: @dismiss
        div className: 'lenny', "( ͡° ͜ʖ ͡°) doesn't see any problems. Relax, man."

    div className: 'tool-panel panel-bottom padded', style: {display},
      div className: 'pull-right',
        a href: '#', className: 'icon icon-x', rel: 'dismiss', onClick: @dismiss
      AnalysisResultRow({ analysisResult: item }) for item in @props.items

AnalysisResultRow = React.createClass
  render: ->
    item = @props.analysisResult
    loc = item.location
    text = "#{loc.file}:#{loc.startLine}: #{item.message}"
    div { className: 'text-warning' }, text
