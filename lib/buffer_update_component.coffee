{Model} = require 'theorist'

module.exports =
class BufferUpdateComponent extends Model
  constructor: (@editor, @analysisAPI) ->
    @editor.onDidStopChanging =>
      @analysisAPI.updateFile @editor.getPath(), @editor.getText()
