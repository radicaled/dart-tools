Rename = require './rename'

class RefactoringComponent
  constructor: (@analysisApi) ->
    atom.commands.add 'atom-text-editor', 'dart-tools:rename', =>
      rename = new Rename(@analysisApi)
      editor = atom.workspace.getActiveTextEditor()

      rename.execute(editor)


  enable: =>

  disable: =>
    @dispose()

  dispose: =>


module.exports = RefactoringComponent
