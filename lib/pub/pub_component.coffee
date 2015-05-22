{Emitter} = require 'event-kit'

_ = require 'lodash'
path  = require 'path'
spawn = require('child_process').spawn
PathWatcher = require('pathwatcher')
Utils = require '../utils'
PubStatusView = require './pub_status_view'

class PubComponent
  constructor: () ->
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
      @emitter.emit 'pub-start',
        title: 'Pub Get'
      @run 'get'

  upgrade: =>
    Utils.dartSdkInfo =>
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
    # See https://github.com/atom/node-pathwatcher/issues/50
    # We'll debounce to drop the duplicate event
    PathWatcher.watch pubspecPath, _.debounce runPubGet, 200,
      maxWait: 400

  pubRunningNotification: (pubspecPath) =>
    atom.notifications.addInfo 'Pub is already running, wait a second!'

  # Code to prevent multiple pub processes on the same file

  isRunning: (pubspecPath) =>
    @runningProcesses[pubspecPath] == true

  markAsRunning: (pubspecPath) =>
    @runningProcesses[pubspecPath] = true

  markAsStopped: (pubspecPath) =>
    delete @runningProcesses[pubspecPath]

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
