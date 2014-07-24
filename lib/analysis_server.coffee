{Model} = require 'theorist'
AnalysisResult = require './analysis_result'
spawn = require('child_process').spawn

module.exports =
class AnalysisServer extends Model
  MSG_END_TOKEN: ">>> EOF STDERR\n"

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
    @process.stdin.write(fullPath + "\n")

  processAnalysis: (data) =>
    line = data.toString()
    @recordToBuffer(line)
    @eachMessage (msg) =>
      @emit 'analysis', AnalysisResult.fromDartAnalyzer @cleanOutput(@buffer)

  processError: (data) =>
    line = data.toString()
    console.log '*** An error occurred!', line

  isCommand: (line) =>
    line?.indexOf('>>>') == 0

  isDone: (line) =>
    line?.indexOf(@MSG_END_TOKEN) != -1

  recordToBuffer: (line) =>
    @buffer ||= ''
    @buffer += line

  eachMessage: (cb) ->
    if @isDone(@buffer)
      sanitized = @cleanOutput(@buffer)
      cb(sanitized) if sanitized
      @buffer = ''

  cleanOutput: (line) =>
    idx = line.indexOf(@MSG_END_TOKEN)
    line.slice(0, idx)
