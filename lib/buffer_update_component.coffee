module.exports =
class BufferUpdateComponent
  constructor: (@editor, @analysisAPI) ->
    @editor.onDidStopChanging =>
      @analysisAPI.updateFile @editor.getPath(), @editor.getText()
