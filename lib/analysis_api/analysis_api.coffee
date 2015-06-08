
# TODO: rename the root "AnalysisApi" class to something else
class AnalysisApi
  constructor: (@api) ->

  # @param {string} file
  # @param {int} offset
  # @returns {Proimse<Object>} --> HoverInformation
  getHover: (file, offset) ->
    @api.sendMessage
      method: 'analysis.getHover'
      params:
        file: file
        offset: offset

module.exports = AnalysisApi
