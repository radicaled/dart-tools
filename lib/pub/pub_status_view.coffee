{View} = require 'atom-space-pen-views'

module.exports =
class PubStatusView extends View
  initialize: (params) ->
    @hide()
    atom.workspace.addBottomPanel(item: this)

    atom.workspace.on 'dart-tools:pub-start', (commandName) =>
      @clear()
      @commandName.text(commandName)
      @show()

    atom.workspace.on 'dart-tools:pub-update', (msg) =>
      formatted = msg.replace '\n', "<br />"
      html = "<span>#{formatted}</span>"
      @pubOutput.append(html)

    atom.workspace.on 'dart-tools:pub-error', (msg) =>
      formatted = msg.replace '\n', "<br />"
      html = "<span class='text-error'>#{formatted}</span>"
      @pubOutput.append(html)

    atom.workspaceView.on 'core:cancel', =>
      @hide()

  clear: ->
    @commandName.text('')
    @pubOutput.text('')

  @content: ->
    @div class: 'overlay from-bottom', =>
      @div class: 'pull-right', =>
        @a href: '#', class: 'icon icon-x', rel: 'dismiss', click: 'hide'
      @h2 outlet: 'commandName'
      @div outlet: 'pubOutput'
