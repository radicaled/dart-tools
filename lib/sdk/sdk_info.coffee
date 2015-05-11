rivets = require 'rivets'
Template = require '../templates/template'

class SdkInfo
  constructor: ->
    @view = new View()

  showInfo: (sdkInfo) =>
    @view.version = sdkInfo.sdkPath || '(null)'
    @view.currentSdk = sdkInfo.version || '(null)'
    @view.show()

class View
  shouldShow: false
  version: null
  currentSdk: null

  constructor: ->
    element = Template.get('sdk/sdk_info.html')
    atom.workspace.addBottomPanel(item: element)

    @view = rivets.bind(element, {it: this})

    @listen()

  listen: =>
    atom.workspaceView.on 'core:cancel', =>
      @shouldShow = false

  hide: =>
    @shouldShow = false
  show: =>
    @shouldShow = true

module.exports = SdkInfo
