{View} = require 'atom'

module.exports =
class AnalysisStatusView extends View
  failCount: 0

  @content: ->
    @a class: 'inline-block', =>
      @span class: 'status icon icon-check'
      @span class: 'status-text'

  initialize: (@statusBar) =>
    @subscribe this, 'click', =>
      atom.workspaceView.trigger('dart-tools:problems:show')
      false

  attach: ->
    @statusBar.appendLeft(this)

  afterAttach: ->
    @updateStatus()

  addFailure: ->
    @failCount += 1
    @updateStatus()


  updateStatus: =>
    className = if @failCount > 0 then 'icon-x' else 'icon-check'
    statusText = if @failCount > 0 then "#{@failCount} problems" else 'No problems'

    this.find('.status')
      .removeClass('icon-check icon-x')
      .addClass(className)

    this.find('.status-text').text(statusText)
