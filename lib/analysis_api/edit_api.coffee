
module.exports =
class EditAPI
  constructor: (@api) ->

  format: (file, offset, length) =>
    @api.perform 'edit.format',
      file: file
      selectionOffset: offset
      selectionLength: length
      lineLength: atom.config.get('editor.preferredLineLength')

  getRefactoring: (kind, file, offset, length, validateOnly, options) =>
    @api.perform 'edit.getRefactoring',
      kind: kind
      file: file
      offset: offset
      length: length
      validateOnly: validateOnly
      options: options
