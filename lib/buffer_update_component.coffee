Utils = require './utils'

module.exports =
class BufferUpdateComponent
  constructor: (@editor, @analysisAPI) ->
    @editor.onDidStopChanging =>
      descriptors = @editor.getRootScopeDescriptor()
      # We only support pure Dart files for now
      return unless Utils.isCompatible(editor)
      @analysisAPI.updateFile @editor.getPath(), @editor.getText()
