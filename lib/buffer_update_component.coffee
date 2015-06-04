_ = require 'lodash'
Utils = require './utils'
{CompositeDisposable} = require 'atom'

module.exports =
class BufferUpdateComponent
  constructor: (@editor, @analysisAPI) ->
    @events = new CompositeDisposable()
    @hasOverlay = false
    updateFile = =>
      descriptors = @editor.getRootScopeDescriptor()
      # We only support pure Dart files for now
      return unless Utils.isCompatible(editor)

      # See: https://github.com/dart-lang/sdk/issues/23577
      #
      # Trying to keep this component as simple and straightforward as possible,
      # but the analysis_server package is really fighting me on this.
      if @hasOverlay
        @removeOverlay(@editor)
        @addOverlay(@editor)
      else
        @addOverlay(@editor)

      # This would be the approriate code path if the analysis_server wasn't
      # shitting in my cereal.
      #
      # if @hasOverlay
      #   @changeOverlay(@editor)
      # else
      #   @addOverlay(@editor)
      #   @hasOverlay = true

    @events.add @editor.onDidSave =>
      # https://github.com/dart-lang/sdk/issues/23579
      @removeOverlay(@editor) if Utils.isCompatible(editor)

    # onDidStopChanging fires 300ms after the user stops typing.
    # Therefore, we'll update the file buffer if no new events are received
    # for 500ms after that. That gives us one more chance to receive another
    # onDidStopChanging event and delay the buffer update.
    @events.add @editor.onDidStopChanging _.debounce(updateFile, 500,
      maxWait: 7000)

  addOverlay: (editor) =>
    @hasOverlay = true
    path = @editor.getPath()
    contents = @editor.getText()
    files = {}
    files[path] =
      type: 'add'
      content: contents

    @analysisAPI.updateContent files


  # Need to do a diff on each change, which is unlikely to happen at the moment.
  # INVALID_OVERLAY_ETC if you use offset = 0, length = 0
  changeOverlay: (editor) =>
    throw {msg: "Don't call me, I'll call you."}
    path = @editor.getPath()
    contents = @editor.getText()
    files = {}
    files[path] =
      type: 'change'
      edits: [
        offset: 0,
        length: 0,
        replacement: contents
      ]

    @analysisAPI.updateContent files

  removeOverlay: (editor) =>
    @hasOverlay = false
    path = @editor.getPath()
    files = {}
    files[path] =
      type: 'remove'

    @analysisAPI.updateContent files

  destroy: =>
    @events.dispose()
    # https://github.com/dart-lang/sdk/issues/23579
    @removeOverlay(@editor) if Utils.isCompatible(editor)
