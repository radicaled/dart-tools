{Model} = require 'theorist'
AnalysisResult = require './analysis_result'
spawn = require('child_process').spawn

module.exports =
class AnalysisServer extends Model
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
    @process.stdin.write(fullPath + "\n")

  processAnalysis: (data) =>
    line = data.toString()
    @buffer ||= ''
    @buffer += line    
    if @isDone(@buffer)
      @emit 'analysis', AnalysisResult.fromDartAnalyzer @cleanOutput(@buffer)
      @buffer = ''


  processError: (data) =>
    line = data.toString()
    console.log '*** An error occurred!', line

  isCommand: (line) =>
    line?.indexOf('>>>') == 0

  isDone: (line) =>
    line?.indexOf(">>> EOF STDERR\n") != -1

  cleanOutput: (line) =>
    token = "\n>>> EOF STDERR\n"
    idx = line.indexOf("\n>>> EOF STDERR\n")
    line.slice(0, idx)
