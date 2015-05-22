{Emitter} = require 'event-kit'
spawn = require('child_process').spawn
path  = require 'path'
Utils = require './utils'

class DartTools
  constructor: (@workingDir) ->


  runPubCommand: (cmd, args) =>
    @withSdk (sdkPath) =>
      cmd  = Utils.getExecPath 'pub'
      args = Array(args)
      process = spawn cmd, args,
        cwd: @workingDir


  withSdk: (callback) =>
    sdkPath = atom.config.get 'dart-tools.dartSdkLocation' ||
      process.env.DART_SDK
    callback(sdkPath) if sdkPath

module.exports = DartTools
