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
    sdkPath = @dartSdkPath()
    execPath = if sdkPath then path.join(sdkPath, 'bin', 'dart') else 'dart'
    @whenDartSdkFound =>
      process = spawn execPath, ['--version']
      exitCode = -1;

      process.stderr.on 'data', (data) => buffer += data.toString()
      process.stderr.on 'end', => fxn(buffer)

  @whenDartProject: (fxn) =>
    fxn() if @isDartProject()

  @isDartProject: =>
    rootDirectory = atom.project.getDirectories()[0]
    return false unless rootDirectory
    pubspec = rootDirectory.getFile('pubspec.yaml')
    pubspec.existsSync()

  @isDartFile: (filename = '') =>
    path.extname(filename) == '.dart'

  @isCompatible: (editor) =>
    # We only support pure Dart files for now
    @isDartFile editor.getPath()

  @whenDartSdkFound: (fxn) =>
    # Why is process null??
    process = window.process unless process
    if process
      sdkPath = @dartSdkPath()
      whereCmd = if process.platform == 'win32' then 'where' else 'which'
      if sdkPath
        execPath = path.join(sdkPath, 'bin', 'dart')
        process = spawn whereCmd, [execPath]

        process.on 'exit', (code) =>
          if code == 0
            fxn()
          else
            atom.workspace.emit 'dart-tools:cannot-find-sdk', @dartSdkInfo()
      else
        atom.workspace.emit 'dart-tools:cannot-find-sdk', @dartSdkInfo()
