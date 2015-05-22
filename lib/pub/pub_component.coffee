{Emitter} = require 'event-kit'
DartTools = require '../dart_tools'

path  = require 'path'
spawn = require('child_process').spawn
PathWatcher = require('pathwatcher')
Utils = require '../utils'
PubStatusView = require './pub_status_view'

class PubComponent
  constructor: (@rootPath) ->
    @emitter = new Emitter
    @dartTools = new DartTools(@rootPath)
    @pubStatusView = new PubStatusView(this)
    @observePubspec()

    atom.commands.add 'atom-workspace', 'dart-tools:pub-get', =>
      @get()
    atom.commands.add 'atom-workspace', 'dart-tools:pub-upgrade', =>
      @upgrade()

  run: (args) =>
    process = @dartTools.runPubCommand('pub', args)
    process.stdout.on 'data', (data) =>
      @emitter.emit 'pub-update',
        output: data.toString()
    process.stderr.on 'data', (data) =>
      @emitter.emit 'pub-error',
        output: data.toString()
    process.on 'exit', =>
      @emitter.emit 'pub-finished'

  get: =>
    @dartTools.withSdk =>
      @emitter.emit 'pub-start',
        title: 'Pub Get'
      @run 'get'

  upgrade: =>
    @dartTools.withSdk =>
      @emitter.emit 'pub-start',
        title: 'Pub Upgrade'
      @run 'upgrade'

  observePubspec: =>
    return unless Utils.isDartProject()
    @watcher = PathWatcher.watch path.join(@rootPath, 'pubspec.yaml'), =>
      if atom.config.get 'dart-tools.pubGetOnSave'
        @get()

  # Events

  onPubStart: (callback) =>
    @emitter.on 'pub-start', callback

  onPubUpdate: (callback) =>
    @emitter.on 'pub-update', callback

  onPubError: (callback) =>
    @emitter.on 'pub-error', callback

  onPubFinished: (callback) =>
    @emitter.on 'pub-finished', callback

  destroy: ->
    @emitter.dispose()

module.exports = PubComponent
