{CompositeDisposable} = require 'atom'

{_} = require 'lodash'
Utils = require './utils'

module.exports =
class Formatter
  constructor: (@analysisApi) ->
    @subscriptions = new CompositeDisposable()
    @editorSubscriptions = new CompositeDisposable()

    # Broken as shit at the moment, so not exposed via config UI
    # @subscriptions.add atom.config.observe 'dart-tools.automaticFormat', (newValue) =>
    #   if newValue == true
    #     @editorSubscriptions.add atom.workspace.observeTextEditors @autoformatEditor
    #   else
    #     @editorSubscriptions.dispose()

    @subscriptions.add atom.config.observe 'dart-tools.formatOnSave', (newValue) =>
      if newValue == true
        @editorSubscriptions.add atom.workspace.observeTextEditors @formatOnSave
      else
        @editorSubscriptions.dispose()

  applyEdits: (editor, edits) =>
    for edit in edits
      offset = edit.offset
      length = edit.length
      start = editor.buffer.positionForCharacterIndex(offset)
      end   = editor.buffer.positionForCharacterIndex(offset + length)

      editor.setTextInBufferRange([start, end], edit.replacement)

  updateCaretPosition: (editor, offset, length) =>
    return unless atom.workspace.getActiveTextEditor().id == editor.id

    # HACK: analysis server is returning null for offset, length
    unless offset && length
      start = editor.buffer.positionForCharacterIndex(offset)
      end   = editor.buffer.positionForCharacterIndex(offset + length)

      editor.setSelectedBufferRange([start, end])

  signalError: (error) =>
    return if error.code == 'SERVER_ERROR'
    # please when don't you have an error son
    detail = error.message
    atom.notifications.addWarning "Failed to autoformat current document!",
      detail: detail
    return

  formatEditor: (editor) =>
    descriptors = editor.getRootScopeDescriptor()
    # We only support pure Dart files for now
    return Promise.resolve() unless Utils.isCompatible(editor)
    path = editor.getPath()
    bufferRange = editor.getSelectedBufferRange()
    offset = editor.buffer.characterIndexForPosition(bufferRange.start)
    length = 0
    # length = offset - editor.buffer.characterIndexForPosition(bufferRange.end)

    promise = @analysisApi.edit.format(path, offset, length)
    return promise.then (response) =>
      result = response.result

      if response.error
        @signalError(response.error)
        return;

      @applyEdits(editor, result.edits)
      @updateCaretPosition(editor, result.selectionOffset, result.selectionLength)

  # Event Handlers

  formatOnSave: (editor) =>
    formatting = false;
    @editorSubscriptions.add editor.onDidSave =>
      return if formatting;
      formatting = true;
      @formatEditor(editor).then () =>
        editor.save();
        formatting = false;


  # Broken(ish).
  autoformatEditor: (editor) =>
    @editorSubscriptions.add editor.onDidChange =>
      @formatEditor(editor)

  dispose: =>
    @subscriptions.dispose()
    @editorSubscriptions.dispose()
