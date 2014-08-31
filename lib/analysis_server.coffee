{Model} = require 'theorist'
{_} = require 'lodash'
AnalysisResult = require './analysis_result'
Utils = require './utils'
spawn = require('child_process').spawn
path  = require 'path'
StreamSplitter = require 'stream-splitter'
Q = require 'q'

module.exports =
class AnalysisServer extends Model
  analysisResults: []
  id: 1
  promiseMap = {}

  start: (packageRoot) =>
    promiseMap = {}
    @listenForEvents()
    sdkPath = Utils.dartSdkPath()
    atomConfigRoot = atom.getConfigDirPath()
    args = [
      path.join(atomConfigRoot,
        'packages',
        'dart-tools/dart/analysis_server.dart'),
      "--sdk=#{sdkPath}"
    ]
    cmd = path.join(sdkPath, "bin", "dart")
    Utils.whenDartSdkFound =>
      @process = spawn cmd, args
      @process.stdout.pipe(StreamSplitter("\n")).on 'token', @processMessage


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
    @process?.stdin?.write(msg + "\n")

    deferred = Q.defer()
    promiseMap[obj.id] = deferred
    return deferred.promise

  processMessage: (message) =>
    obj = JSON.parse(message.toString())
    promise = promiseMap[obj.id]

    if obj.event
      @emit "analysis-server:#{obj.event}", obj
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


  listenForEvents: =>
    @subscribe this, 'analysis-server:analysis.errors', (obj) =>
      @emit 'refresh', obj.params.file
      for error in obj.params.errors
        @emit 'analysis', error
