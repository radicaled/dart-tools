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
