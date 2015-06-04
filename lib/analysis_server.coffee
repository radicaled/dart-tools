{Emitter} = require 'event-kit'
{_} = require 'lodash'
Utils = require './utils'
spawn = require('child_process').spawn
path  = require 'path'
StreamSplitter = require 'stream-splitter'
Q = require 'q'
SdkService = require './sdk/sdk_service'

module.exports =
class AnalysisServer
  id: 1
  promiseMap = {}
  isRunning: false
  currentAnalysisRoots: new Set()

  constructor: ->
    @emitter = new Emitter()

  start: (analysisRoots) =>
    promiseMap = {}
    sdkPath = SdkService.getActiveSdkPath()
    atomConfigRoot = atom.getConfigDirPath()
    args = [
      path.join(sdkPath,
        "bin",
        "snapshots",
        "analysis_server.dart.snapshot")
    ]
    cmd = Utils.getExecPath 'dart'
    Utils.whenDartSdkFound =>
      @process = spawn cmd, args
      @isRunning = true
      @process.stdout.pipe(StreamSplitter("\n")).on 'token', @processMessage
      @process.on 'exit', =>
        @isRunning = false

      # Set analysis root.
      @setAnalysisRoots analysisRoots

  stop: =>
    @process?.kill()

  sendMessage: (obj) =>
    return unless @isRunning
    obj.id ||= "dart-tools-#{(@id++)}"
    msg = JSON.stringify(obj)
    @process.stdin.write(msg + "\n")

    console.log "SENT", msg
    deferred = Q.defer()
    promiseMap[obj.id] = deferred
    return deferred.promise

  processMessage: (message) =>
    obj = JSON.parse(message.toString())
    promise = promiseMap[obj.id]

    console.log "RECV", message.toString()

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
    else if obj.error?
      delete promiseMap[obj.id]
      promise?.reject(obj.error)
    else if obj.result?.id # An ID for an incoming event stream
      delete promiseMap[obj.id]
      promiseMap[obj.result.id] = promise
    else # A one off event, resolve immediately
      delete promiseMap[obj.id]
      promise?.resolve(obj)

  forEachEvent: (callback) =>
    @emitter.on 'new-event', (obj) =>
      callback(obj.event, obj)

  setAnalysisRoots: (paths) =>
    @currentAnalysisRoots = new Set(paths)
    @sendMessage
      method: "analysis.setAnalysisRoots"
      params:
        included: paths
        excluded: []
