_ = require 'lodash'
spawn = require('child_process').spawn
path  = require 'path'
SdkService        = require './sdk/sdk_service'
PlatformService   = require './platform/platform_service'

module.exports =
class Utils
  # TODO: find and replace all instances with PlatformService.getExecutable
  @getExecutable: (cmd) =>
    PlatformService.getExecutable(cmd)

  # TODO: find and replace all instances with SdkService.getActiveSdkPath
  @getExecPath: (cmd) =>
    SdkService.getCommandPath(cmd)

  @whenEditor: (fxn) =>
    editor = atom.workspace.getActiveTextEditor()
    fxn(editor) if editor

  @dartSdkInfo: (fxn) =>
    sdkInfo =
      sdkPath: SdkService.getActiveSdkPath()
      envPath: process.env.DART_SDK
    if fxn
      @dartVersion (dartVersion) =>
        sdkInfo.version = dartVersion
        fxn(sdkInfo)

    sdkInfo

  @dartVersion: (fxn) =>
    buffer = ''
    execPath = @getExecPath 'dart'
    @whenDartSdkFound =>
      process = spawn execPath, ['--version']
      exitCode = -1

      process.stderr.on 'data', (data) => buffer += data.toString()
      process.stderr.on 'end', => fxn(buffer)

  @whenDartProject: (fxn) =>
    fxn() if @isDartProject()

  @isDartProject: =>
    @getDartProjectPaths().length > 0

  @getDartProjectPaths: =>
    filter = (dir) ->
      dir.getFile('pubspec.yaml').existsSync() or dir.getFile('.packages').existsSync()
    (dir for dir in atom.project.getDirectories() when filter(dir)).map((d) => d.path)

  @isDartFile: (filename = '') =>
    path.extname(filename) is '.dart'

  @isCompatible: (editor) =>
    # We only support pure Dart files for now
    @isDartFile editor.getPath()

  @findProjectRootInAtom: (path) =>
    directories = atom.project.getDirectories()
    dir = _.find(directories, (d) => d.contains(path))
    dir?.getPath()

  @canAnalyze: (editor) =>
    filename = editor.getPath()
    projectPath = @findProjectRootInAtom(filename)

    @isCompatible(editor) and projectPath

  @whenDartSdkFound: (fxn) =>
    # Why is process null??
    process = window.process unless process
    if process
      execPath = @getExecPath 'dart'
      return false unless execPath
      process = spawn execPath, ['--version']

      process.on 'exit', (code) =>
        if code is 0
          fxn()

  @deferred: =>    
    resolve = null
    reject = null
    promise = new Promise =>
      resolve = arguments[0]
      reject = arguments[1]

    return {
      resolve: resolve
      reject: reject
      promise: promise
    }
