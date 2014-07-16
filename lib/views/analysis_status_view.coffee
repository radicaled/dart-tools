{View} = require 'atom'
React = require 'react-atom-fork'
{_} = require 'lodash'

{a, div, span} = require 'reactionary-atom-fork'

module.exports =
class AnalysisStatusView extends View
  Object.defineProperty @::, 'analysisCount', get: -> @items.length
  items: []

  @content: ->
    @div class: 'inline-block'

  initialize: (@statusBar) =>
    @subscribe atom.workspace, 'dart-tools:analysis', (result) =>
      @items.push(result)
      @updateState()
      return null

    @subscribe atom.workspace, 'dart-tools:refresh', (fullPath) =>
      _.remove @items, (item) => item.fullpath == fullPath
      @updateState()
      return null

  attach: ->
    @statusBar.appendLeft(this)

  afterAttach: ->
    @component = React.renderComponent (StatusBar {items: @items }), @element

  updateState: ->
    @component.setState({ items: @items })

StatusBar = React.createClass
  showAnalysis: (e) ->
    atom.workspaceView.trigger('dart-tools:problems:show')
    e.preventDefault()
    return false

  render: ->
    length = @props.items.length
    className = if length > 0 then 'icon icon-x' else 'icon icon-check'
    statusText = if length > 0 then "#{length} problems" else 'No problems'
    div {},
      a { href: '#', onClick: @showAnalysis },
        span className: className
        span className: 'status-text', @props.items.length, " problems"
