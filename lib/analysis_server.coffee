{Model} = require 'theorist'
{_} = require 'lodash'
AnalysisResult = require './analysis_result'
spawn = require('child_process').spawn

module.exports =
class AnalysisServer extends Model
  MSG_END_TOKEN: '\n'
  FILE_END_TOKEN: ">>> EOF STDERR"
  analysisResults: []

  start: (packageRoot) =>
    args = [
      "-b",
      "-p",
      packageRoot,
      "--format=machine"
    ]
    cmd = "dartanalyzer"
    @process = spawn cmd, args
    @process.stderr.on 'data', @processAnalysis
    #@process.stderr.on 'data', @processError

  stop: =>
    @process?.close()

  check: (fullPath) =>
    @emit 'refresh', fullPath
    @process?.stdin?.write(fullPath + "\n")

  processAnalysis: (data) =>
    line = data.toString()
    @recordToBuffer(line)
    # Waiting for the entire analysis to complete (for a file at least)
    # isn't ideal. However, the analyzer API makes it difficult to deal with
    # at the moment
    if @isDone(@buffer)
      @eachMessage (msg) =>
        @emit 'analysis', AnalysisResult.fromDartAnalyzer msg
      @buffer = ''

  processError: (data) =>
    line = data.toString()
    console.log '*** An error occurred!', line

  isCommand: (line) =>
    line?.indexOf('>>>') == 0

  isDone: (line) =>
    line?.indexOf(@FILE_END_TOKEN) != -1

  recordToBuffer: (line) =>
    @buffer ||= ''
    @buffer += line

  eachMessage: (cb) ->
    @analysisResults.push.apply @analysisResults, @buffer.split(@MSG_END_TOKEN)
    _.remove @analysisResults, (msg) => msg.length == 0 || @isCommand(msg)
    while @analysisResults.length > 0
      result = @analysisResults.pop()
      cb(result)

  cleanOutput: (line) =>
    idx = line.indexOf(@MSG_END_TOKEN)
    line.slice(0, idx)
