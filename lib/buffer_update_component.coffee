Utils = require './utils'
{CompositeDisposable} = require 'atom'

module.exports =
class BufferUpdateComponent
  constructor: (@editor, @analysisAPI) ->
    @events = new CompositeDisposable()
    @events.add @editor.onDidStopChanging =>
      descriptors = @editor.getRootScopeDescriptor()
      # We only support pure Dart files for now
      return unless Utils.isCompatible(editor)
      @analysisAPI.updateFile @editor.getPath(), @editor.getText()

  destroy: =>
    @events.dispose()
