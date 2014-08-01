module.exports =
class Utils
  @whenEditor: (fxn) =>
    editor = atom.workspace.getActiveEditor()
    fxn(editor) if editor    
