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
      @attach()
      @show()

    @subscribe atom.workspaceView, 'dart-tools:problems:hide', =>
      @hide()

    @subscribe atom.workspace, 'dart-tools:analysis', (result) =>
      @items.push(result)
      return null

    @subscribe atom.workspace, 'dart-tools:refresh', (fullPath) =>
      _.remove @items, (item) => item.fullpath == fullPath
      return null
    this

  attach: ->
    atom.workspaceView.appendToBottom(this)

  afterAttach: ->
    @component = React.renderComponent (AnalysisPanel {items: @items }), @element

  updateState: ->
    @component.setState({ items: @items })

AnalysisPanel = React.createClass

  dismiss: (e) ->
    atom.workspaceView.trigger 'dart-tools:problems:hide'
    e.preventDefault()
    return false

  render: ->
    unless @props.items
      return div className: 'lenny', "( ͡° ͜ʖ ͡°) doesn't see any problems. Relax, man."

    div className: 'tool-panel panel-bottom padded',
      div className: 'pull-right',
        a href: '#', className: 'icon icon-x', rel: 'dismiss', onClick: @dismiss
      AnalysisResultRow({ analysisResult: item }) for item in @props.items

AnalysisResultRow = React.createClass
  render: ->
    console.log 'rendering this: #{item}'
    item = @props.analysisResult
    text = "#{item.fullpath}:#{item.line}: #{item.desc}"
    div { className: 'text-warning' }, text
