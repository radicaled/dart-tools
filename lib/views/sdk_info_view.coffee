{View} = require 'atom-space-pen-views'
Utils = require '../utils'

module.exports =
class SdkInfo extends View
  @content: (sdkInfo)->
    sdkPath = sdkInfo.sdkPath || '(null)'
    envPath = sdkInfo.envPath || '(null)'
    version = sdkInfo.version || '(null)'

    @div class: 'overlay from-bottom', =>
      @h2 class: 'text-info', 'Dart SDK information'
      @p =>
        @h3 class: 'text-highlight', "Version"
        @span class: 'text-info', version
      @p =>
        @h3 class: 'text-highlight', "Working SDK path:"
        @span class: 'text-info', Utils.dartSdkPath()

  initialize: (@sdkInfo) ->
    @subscribe atom.workspaceView, 'core:cancel', =>
      @remove()
