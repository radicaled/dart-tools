{Emitter} = require 'event-kit'
spawn = require('child_process').spawn
path  = require 'path'

class DartTools
  constructor: (@workingDir) ->


  runPubCommand: (cmd, args) =>
    @withSdk (sdkPath) =>
      cmd  = path.join(sdkPath, 'bin', 'pub')
      args = Array(args)
      process = spawn cmd, args,
        cwd: @workingDir


  withSdk: (callback) =>
    sdkPath = atom.config.get 'dart-tools.dartSdkLocation' ||
      process.env.DART_SDK
    callback(sdkPath) if sdkPath

module.exports = DartTools
