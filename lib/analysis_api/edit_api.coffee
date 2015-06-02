
module.exports =
class EditAPI
  constructor: (@api) ->

  format: (file, offset, length) =>
    @api.perform 'edit.format',
      file: file
      selectionOffset: offset
      selectionLength: length
      lineLength: atom.config.get('editor.preferredLineLength')
