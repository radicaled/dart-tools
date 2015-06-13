rivets = require 'rivets'
Template = require '../templates/template'

class Rename

  constructor: (@analysisApi) ->


  execute: (editor) =>
    editor.selectWordsContainingCursors()
    word = editor.getSelectedText()



    promise = new Promise (resolve, reject) =>
      view = new View(resolve, reject)
      view.setText(word)
      view.show()

    promise.then(
      (newName) => @handleConfirm(editor, newName)
      @handleCancel
    )

  handleConfirm: (editor, newName) =>
    kind = 'RENAME'
    file = editor.getPath()
    bufferPosition = editor.getCursorBufferPosition()
    offset = editor.buffer.characterIndexForPosition(bufferPosition)
    word = editor.getSelectedText()
    length = word.length

    options =
      newName: newName
    promise = @analysisApi.edit.getRefactoring(kind, file, offset, length, false, options)
    promise.then(@handleRefactor, @handleRefactorError)

  handleCancel: (reason) =>
    atom.notifications.addWarning("Cancelled: #{reason}")

  handleRefactor: (data) =>
    result = data.result
    problems = [].concat(result.optionsProblems).concat(result.finalProblems)
    if problems.length > 0
      @showRefactorWarning(problems)
      return

    for edit in result.change.edits
      @updateBufferWithEdit(edit)


    successMessage = "Renamed #{result.feedback.oldName}"
    atom.notifications.addInfo successMessage


  handleRefactorError: (data) =>
    atom.notifications.addWarning 'Could not complete refactoring',
      detail: data.error

  showRefactorWarning: (errors) =>
    atom.notifications.addWarning 'Failed to rename element',
      detail: (error.message for error in errors).join("\n")

  updateBufferWithEdit: (edit) =>
    # Using some dark voodoo here by using Project internals
    updateBuffer = (buffer) =>
      for regionEdit in edit.edits
        offset = regionEdit.offset
        length = regionEdit.length
        start = buffer.positionForCharacterIndex(offset)
        end   = buffer.positionForCharacterIndex(offset + length)

        buffer.setTextInRange([start, end], regionEdit.replacement)
        buffer.save()

    existingBuffer = atom.project.findBufferForPath(edit.file)
    if existingBuffer
      updateBuffer(existingBuffer)
    else
      atom.project.buildBuffer(edit.file).then (buffer) =>
        updateBuffer(buffer)
        atom.project.removeBuffer(buffer)

class View

  constructor: (@resolve, @reject) ->
    element = Template.get('refactoring/rename.html')
    @panel = atom.workspace.addModalPanel(item: element, visible: false)
    @view = rivets.bind(element, {it: this})
    @editor = element.querySelector('#editor')
    @model = @editor.model

    atom.commands.add 'atom-workspace', 'core:cancel', => @cancel()
    atom.commands.add 'atom-workspace', 'core:confirm', => @confirm()

  show: =>
    @panel.show()
    @editor.focus()
  hide: => @panel.hide()

  confirm: =>
    @resolve(@model.getText())
    @hide()

  cancel: =>
    @reject('Cancelled refactoring')
    @hide()

  setText: (text) => @model.setText(text)

  dispose: =>
    @panel.destroy()


module.exports = Rename
