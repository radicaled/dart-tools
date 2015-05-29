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

    # onDidStopChanging fires 300ms after the user stops typing.
    # Therefore, we'll update the file buffer if no new events are received
    # for 500ms after that. That gives us one more chance to receive another
    # onDidStopChanging event and delay the buffer update.
    @events.add @editor.onDidStopChanging _.debounce(updateFile, 500,
      maxWait: 7000)

  destroy: =>
    @events.dispose()
