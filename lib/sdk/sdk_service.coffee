fs    = require 'fs'
path  = require 'path'
which = require 'which'
PlatformService = require '../platform/platform_service'

class SdkService
  @discoverSdkPath: =>
    cmd = PlatformService.getExecutable 'dart'
    cmdLocation = ''
    try
      cmdLocation = which.sync(cmd)
    catch error
      console.log 'Error:', error
      return
    # cmdLocation will be something like "/usr/local/opt/dart/bin/dart"
    # we need to get to "/usr/local/opt/dart/"
    path.join(cmdLocation, '..', '..')

  @getActiveSdkPath: =>
    configuredSdk = atom.config.get 'dart-tools.dartSdkLocation'
    configuredSdk or
      process.env.DART_SDK or
      @discoverSdkPath() or
      ''

  @getCommandPath: (command) =>
    sdkPath = @getActiveSdkPath()
    unless sdkPath
      throw new Error("No valid Dart SDK found; cannot execute #{command}")
    dartCmd = PlatformService.getExecutable command
    execPath = path.join(sdkPath, 'bin', dartCmd)

module.exports = SdkService
