
# TODO: rename the root "AnalysisApi" class to something else
class AnalysisApi
  constructor: (@api) ->

  # @param {Hash<AnalysisService, List<FilePath>} subscriptions -->
  setSubscriptions: (subscriptions) =>
    @api.sendMessage
      method: 'analysis.setSubscriptions'
      params:
        subscriptions: subscriptions

  getLibraryDependencies: =>
    @api.sendMessage
      method: 'analysis.getLibraryDependencies'

  # @param {string} file
  # @param {int} offset
  # @returns {Proimse<Object>} --> HoverInformation
  getHover: (file, offset) ->
    @api.sendMessage
      method: 'analysis.getHover'
      params:
        file: file
        offset: offset

  # @param {string} file
  # @param {int} offset
  # @param {int} length
  getNavigation: (file, offset, length) =>
    @api.sendMessage
      method: 'analysis.getNavigation'
      params:
        file: file
        offset: offset
        length: length

module.exports = AnalysisApi
