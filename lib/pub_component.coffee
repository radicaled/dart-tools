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

  get: =>
    @run 'get'

  observePubspec: =>
    chokidar = require 'chokidar'
    @watcher = chokidar.watch path.join(@rootPath, 'pubspec.yaml'), ignoreInitial: true
    @watcher.on 'change', (pathname) =>
      if atom.config.get 'dart-tools.automaticPubGet'
        @get()
