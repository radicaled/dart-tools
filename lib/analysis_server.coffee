{Emitter} = require 'event-kit'
{_} = require 'lodash'
Utils = require './utils'
spawn = require('child_process').spawn
path  = require 'path'
StreamSplitter = require 'stream-splitter'
Q = require 'q'

module.exports =
class AnalysisServer
  FAILURE_HARD_STOP: 3
  FAILURE_HARD_STOP_TIMEOUT: 30
  id: 1
  promiseMap = {}
  serverFailureCount: 0
  writable: false

  constructor: ->
    @emitter = new Emitter()

  start: (packageRoot) =>
    promiseMap = {}
    sdkPath = Utils.dartSdkPath()
    atomConfigRoot = atom.getConfigDirPath()
    args = [
      path.join(sdkPath,
        "bin",
        "snapshots",
        "analysis_server.dart.snapshot")
    ]
    cmd = path.join(sdkPath, "bin", "dart")
    Utils.whenDartSdkFound =>
      @process = spawn cmd, args
      @writable = true
      @process.stdout.pipe(StreamSplitter("\n")).on 'token', @processMessage
      @process.on 'exit', =>
        @writable = false
        @serverFailureCount += 1

        setTimeout (=> @serverFailureCount = 0), @FAILURE_HARD_STOP_TIMEOUT * 1000


        if @serverFailureCount < @FAILURE_HARD_STOP
          @start()
        else
          console.log 'Could not run analysis server. :/'

      # Set analysis root.
      @sendMessage
        method: "analysis.setAnalysisRoots"
        params:
          included: [packageRoot]
          excluded: []

  stop: =>
    @process?.close()

  # Not sure this method is needed, but adding for
  # compatibility
  check: (fullPath) =>
    @emit 'refresh', fullPath
    @sendMessage
      method: "analysis.reanalyze"
      params:
        file: fullPath


  sendMessage: (obj) =>
    obj.id ||= "dart-tools-#{(@id++)}"
    msg = JSON.stringify(obj)
    if @writable
      @process?.stdin?.write(msg + "\n")

    deferred = Q.defer()
    promiseMap[obj.id] = deferred
    return deferred.promise

  processMessage: (message) =>
    obj = JSON.parse(message.toString())
    promise = promiseMap[obj.id]

    if obj.event
      @emitter.emit 'new-event', obj
      id = obj.params?.id
      promise = promiseMap[id]

      if obj.params?.hasOwnProperty('isLast')
        if obj.params.isLast
          delete promiseMap[id]
          promise?.resolve(obj)
        else
          promise?.notify(obj)
      else
        delete promiseMap[id]
        promise?.resolve(obj)

    else if obj.result # An ID for an incoming event stream
      delete promiseMap[obj.id]
      promiseMap[obj.result.id] = promise
    else # A one off event, resolve immediately
      delete promiseMap[obj.id]
      promise?.resolve(obj)

  forEachEvent: (callback) =>
    @emitter.on 'new-event', (obj) =>
      callback(obj.event, obj)
