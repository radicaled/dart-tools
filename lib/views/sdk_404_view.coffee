{View} = require 'atom-space-pen-views'

module.exports =
class Sdk404View extends View
  @content: (sdkInfo) ->
    sdkPath = sdkInfo.sdkPath || '(null)'
    envPath = sdkInfo.envPath || '(null)'

    @div class: 'overlay from-bottom', =>
      @h2 class: 'text-error', 'Could not find Dart SDK'
      @h3 "Here's what I know:"
      @p =>
        @span class: 'text-info', "dart-tools.dartSdkLocation configuration value:"
        @br()
        @strong sdkPath
      @p =>
        @span class: 'text-info', "DART_SDK environment variable:"
        @br()
        @strong envPath

  initialize: (sdkInfo) ->
    @subscribe atom.workspaceView, 'core:cancel', =>
      @remove()
