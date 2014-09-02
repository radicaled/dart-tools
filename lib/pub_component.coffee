path  = require 'path'
spawn = require('child_process').spawn
PathWatcher = require('pathwatcher')
Utils = require './utils'
PubStatusView = require './views/pub_status_view'

module.exports =
class PubComponent
  constructor: (@rootPath) ->
    @pubStatusView = new PubStatusView()
    @observePubspec()

  run: (args) =>
    sdkPath = Utils.dartSdkPath()
    cmd  = if sdkPath then path.join(sdkPath, 'bin', 'pub') else 'pub'
    args = Array(args)
    @process = spawn cmd, args,
      cwd: @rootPath
    @process.stdout.on 'data', (data) =>
      atom.workspace.emit('dart-tools:pub-update', data.toString())
    @process.stderr.on 'data', (data) =>
      atom.workspace.emit('dart-tools:pub-error', data.toString())

  get: =>
    Utils.whenDartSdkFound =>
      atom.workspace.emit('dart-tools:pub-start', 'Pub Get')
      @run 'get'

  observePubspec: =>
    return unless Utils.isDartProject()
    @watcher = PathWatcher.watch path.join(@rootPath, 'pubspec.yaml'), =>
      if atom.config.get 'dart-tools.automaticPubGet'
        @get()
