module.exports =
class Utils
  @whenEditor: (fxn) =>
    editor = atom.workspace.getActiveEditor()
    fxn(editor) if editor
  @dartSdkPath: =>
    atom.config.get 'dart-tools.dartSdkLocation' ||
      process.env.DART_SDK ||
      ''
