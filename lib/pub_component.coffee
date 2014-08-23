path  = require 'path'
spawn = require('child_process').spawn
PathWatcher = require('pathwatcher')
Utils = require './utils'

module.exports =
class PubComponent
  constructor: (@rootPath) ->
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
    atom.workspace.emit('dart-tools:pub-start', 'Pub Get')
    @run 'get'

  observePubspec: =>
    @watcher = PathWatcher.watch path.join(@rootPath, 'pubspec.yaml'), =>
      if atom.config.get 'dart-tools.automaticPubGet'
        @get()
