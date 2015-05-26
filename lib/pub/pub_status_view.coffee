rivets = require 'rivets'
Template = require '../templates/template'

class PubStatusView
  @title        = ''
  @output       = ''

  constructor: (@pubComponent) ->
    element = Template.get('pub/pub_status_view.html')
    @panel = atom.workspace.addModalPanel(item: element, visible: false)
    atom.commands.add 'atom-workspace', 'core:cancel', =>
      @panel.hide()
    @view = rivets.bind(element, {it: this})
    @listen()

  listen: =>
    asHtml = (input, textClass) =>
      textClass = '' unless textClass
      formatted = input.replace new RegExp('\n', 'g'), "<br>"
      "<span class=\"#{textClass}\">#{formatted}</span>"

    @pubComponent.onPubStart (data) =>
      @title = data.title
      @output = ''
      @panel.show()

    @pubComponent.onPubUpdate (data) =>
      @output = @output + asHtml(data.output)

    @pubComponent.onPubError (data) =>
      @output = @output + asHtml(data.output, 'text-error')

    @pubComponent.onPubFinished (data) =>
      @title = @title + ' (Finished)'

  hide: =>
    @panel.hide()

module.exports = PubStatusView
