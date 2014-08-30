{Model} = require 'theorist'

module.exports =
class BufferUpdateComponent extends Model
  constructor: (@editor, @analysisAPI) ->
    @subscribe @editor, 'contents-modified', =>      
      @analysisAPI.updateFile @editor.getPath(), @editor.getText()
