{Model} = require 'theorist'
{_} = require 'lodash'
AnalysisResult = require './analysis_result'
Utils = require './utils'
spawn = require('child_process').spawn
path  = require 'path'
StreamSplitter = require 'stream-splitter'

module.exports =
class AnalysisServer extends Model
  analysisResults: []
  id: 1

  start: (packageRoot) =>
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
    obj.id ||= (@id++).toString();
    msg = JSON.stringify(obj)
    console.log 'sending this', msg
    @process?.stdin?.write(msg + "\n")

  processMessage: (message) =>
    obj = JSON.parse(message.toString())
    if obj.event
      @emit "analysis-server:#{obj.event}", obj
    console.log('Received:', message.toString())

  listenForEvents: =>
    @subscribe this, 'analysis-server:analysis.errors', (obj) =>
      @emit 'refresh', obj.file
      for error in obj.params.errors
        @emit 'analysis', error
      console.log 'Received', obj
