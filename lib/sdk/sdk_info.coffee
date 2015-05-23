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
  shouldShow: false
  sdkPath: null
  sdkVersion: null

  constructor: ->
    element = Template.get('sdk/sdk_info.html')
    atom.workspace.addBottomPanel(item: element)

    @view = rivets.bind(element, {it: this})

    @listen()

  listen: =>
    atom.commands.add 'atom-text-editor', 'core:cancel', =>
      @shouldShow = false

  hide: =>
    @shouldShow = false
  show: =>
    @shouldShow = true

module.exports = SdkInfo
