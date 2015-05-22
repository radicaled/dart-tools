_ = require 'lodash'
spawn = require('child_process').spawn
path  = require 'path'

module.exports =
class Utils
  @windowsCmdMap =
    pub: 'pub.bat'
    dart: 'dart.exe'

  @getExecutable: (cmd) =>
    isWin = /^win/.test(process.platform);
    return cmd unless isWin
    windowsCmd = @windowsCmdMap[cmd]
    return windowsCmd || cmd

  @getExecPath: (cmd) =>
    sdkPath = @dartSdkPath()
    dartCmd = @getExecutable cmd
    execPath = if sdkPath then path.join(sdkPath, 'bin', dartCmd) else dartCmd

  @whenEditor: (fxn) =>
    editor = atom.workspace.getActiveEditor()
    fxn(editor) if editor

  @dartSdkPath: =>
    atom.config.get 'dart-tools.dartSdkLocation' ||
      process.env.DART_SDK ||
      ''

  @dartSdkInfo: (fxn) =>
    sdkInfo =
      sdkPath: atom.config.get 'dart-tools.dartSdkLocation'
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
      exitCode = -1;

      process.stderr.on 'data', (data) => buffer += data.toString()
      process.stderr.on 'end', => fxn(buffer)

  @whenDartProject: (fxn) =>
    fxn() if @isDartProject()

  @isDartProject: =>
    @getDartProjectPaths() != null

  @getDartProjectPaths: =>
    _(atom.project.getDirectories())
      .where (dir) ->
        pubspecFile = dir.getFile('pubspec.yaml')
        packagesFile = dir.getFile('.packages')
        pubspecFile.existsSync() || packagesFile.existsSync()
      .map (dir) -> dir.path
      .value()

  @isDartFile: (filename = '') =>
    path.extname(filename) == '.dart'

  @isCompatible: (editor) =>
    # We only support pure Dart files for now
    @isDartFile editor.getPath()

  @whenDartSdkFound: (fxn) =>
    # Why is process null??
    process = window.process unless process
    if process
      execPath = @getExecPath 'dart'
      process = spawn execPath, ['--version']

      process.on 'exit', (code) =>
        if code == 0
          fxn()
