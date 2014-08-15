path  = require 'path'
spawn = require('child_process').spawn

module.exports =
class PubComponent
  constructor: (@rootPath) ->
    @observePubspec()

  run: (args) =>
    cmd  = 'pub'
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
    chokidar = require 'chokidar'
    @watcher = chokidar.watch path.join(@rootPath, 'pubspec.yaml'), ignoreInitial: true
    @watcher.on 'change', (pathname) =>
      if atom.config.get 'dart-tools.automaticPubGet'
        @get()
