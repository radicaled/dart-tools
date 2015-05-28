_ = require 'lodash'
Utils = require './utils'
{CompositeDisposable} = require 'atom'

module.exports =
class BufferUpdateComponent
  constructor: (@editor, @analysisAPI) ->
    @events = new CompositeDisposable()
    updateFile = =>
      descriptors = @editor.getRootScopeDescriptor()
      # We only support pure Dart files for now
      return unless Utils.isCompatible(editor)
      @analysisAPI.updateFile @editor.getPath(), @editor.getText()

    @events.add @editor.onDidStopChanging _.debounce(updateFile, 250,
      maxWait: 1000)

  destroy: =>
    @events.dispose()
