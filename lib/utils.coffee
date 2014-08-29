spawn = require('child_process').spawn
path  = require 'path'

module.exports =
class Utils
  @whenEditor: (fxn) =>
    editor = atom.workspace.getActiveEditor()
    fxn(editor) if editor

  @dartSdkPath: =>
    atom.config.get 'dart-tools.dartSdkLocation' ||
      process.env.DART_SDK ||
      ''

  @whenDartProject: (fxn) =>
    fxn() if @isDartProject

  @isDartProject: =>
    pubspec = atom.project.getRootDirectory().getFile('pubspec.yaml')
    pubspec.exists()

  @whenDartSdkFound: (fxn) =>
    # Why is process null??
    process = window.process unless process
    if process
      sdkPath = @dartSdkPath()
      whereCmd = if process.platform == 'win32' then 'where' else 'which'
      execPath = if sdkPath then path.join(sdkPath, 'bin', 'dart') else 'dart'

      process = spawn whereCmd, [execPath]

      process.on 'exit', (code) =>
        if code == 0
          fxn()
        else
          atom.workspace.emit 'dart-tools:cannot-find-sdk'
