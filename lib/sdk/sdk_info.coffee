rivets = require 'rivets'
Template = require '../templates/template'

class SdkInfo
  constructor: ->
    @view = new View()

  showInfo: (sdkInfo) =>
    @view.sdkPath = sdkInfo.sdkPath or '(null)'
    @view.sdkVersion = sdkInfo.version or '(null)'
    @view.show()

class View
  sdkPath: null
  sdkVersion: null

  constructor: ->
    element = Template.get('sdk/sdk_info.html')
    @panel = atom.workspace.addModalPanel(item: element, visible: false)
    @view = rivets.bind(element, {it: this})
    @listen()

  listen: =>
    atom.commands.add 'atom-text-editor', 'core:cancel', =>
      @panel.hide()

  hide: =>
    @panel.hide()

  show: =>
    @panel.show()

module.exports = SdkInfo
