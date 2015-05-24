{Emitter} = require 'event-kit'

_ = require 'lodash'
path  = require 'path'
spawn = require('child_process').spawn
fs = require('fs')
Utils = require '../utils'
PubStatusView = require './pub_status_view'

class PubComponent
  constructor: ->
    @emitter = new Emitter
    @pubStatusView = new PubStatusView(this)
    @watchers = []
    @runningProcesses = {}

    watchProjectPaths = =>
      _.each Utils.getDartProjectPaths(), (pp) =>
        @watchers.push @observePubspec(pp)

    atom.project.onDidChangePaths =>
      _.invoke @watchers, 'close'
      @watchers = []
      watchProjectPaths()

    watchProjectPaths()

    atom.commands.add 'atom-workspace', 'dart-tools:pub-get', =>
      @get()
    atom.commands.add 'atom-workspace', 'dart-tools:pub-upgrade', =>
      @upgrade()

  run: (args) =>
    # TODO / HACK: need to operate on multiple valid projects
    pubspecRoot = Utils.getDartProjectPaths()[0]
    pubspecPath = path.join pubspecRoot, 'pubspec.yaml'
    return unless pubspecRoot

    if @isRunning(pubspecPath)
      @pubRunningNotification pubspecPath
      return

    Utils.dartSdkInfo (sdkInfo) =>
      cmd  = Utils.getExecPath 'pub'
      args = Array(args)

      @markAsRunning pubspecPath

      process = spawn cmd, args,
        cwd: pubspecRoot
      process.stdout.on 'data', (data) =>
        @emitter.emit 'pub-update',
          output: data.toString()
      process.stderr.on 'data', (data) =>
        @emitter.emit 'pub-error',
          output: data.toString()
      process.on 'exit', =>
        @markAsStopped pubspecPath
        @emitter.emit 'pub-finished'

  get: =>
    Utils.dartSdkInfo =>
      @whenPubspecPresent =>
        @emitter.emit 'pub-start',
          title: 'Pub Get'
        @run 'get'

  upgrade: =>
    Utils.dartSdkInfo =>
      @whenPubspecPresent =>
        @emitter.emit 'pub-start',
          title: 'Pub Upgrade'
        @run 'upgrade'

  observePubspec: (pubspecRoot) =>
    pubspecPath = path.join pubspecRoot, 'pubspec.yaml'
    runPubGet = =>
      if @isRunning(pubspecPath)
        @pubRunningNotification pubspecPath
        return
      if atom.config.get 'dart-tools.pubGetOnSave'
        @get()
    # We'll debounce to drop any duplicate events
    # Unfortunately fs.watch has the same problem as pathwatcher.
    fs.watch pubspecPath, _.debounce(runPubGet, 3000, leading: true, trailing: false)

  pubRunningNotification: (pubspecPath) =>
    atom.notifications.addInfo 'Pub is already running, wait a second!'

  # Code to prevent multiple pub processes on the same file

  isRunning: (pubspecPath) =>
    @runningProcesses[pubspecPath] is true

  markAsRunning: (pubspecPath) =>
    @runningProcesses[pubspecPath] = true

  markAsStopped: (pubspecPath) =>
    delete @runningProcesses[pubspecPath]

  # Helpers

  whenPubspecPresent: (callback) =>
    return unless Utils.getDartProjectPaths().length > 0
    pubspecRoot = Utils.getDartProjectPaths()[0]
    pubspecPath = path.join pubspecRoot, 'pubspec.yaml'
    return unless fs.existsSync(pubspecPath)
    callback()

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
    _.invoke @watchers, 'close'
    @watchers = []

module.exports = PubComponent
