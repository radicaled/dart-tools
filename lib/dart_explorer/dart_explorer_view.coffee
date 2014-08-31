{ScrollView} = require 'atom'

module.exports =
class DartExplorerView extends ScrollView
  @content: ->
    @div =>
      @h2 'Hello, World!'

  initialize: (@project, @api) =>
    promise = @api.search.findTopLevelDeclarations 'String'
    promise.then (obj) =>
      console.log 'I got this:', obj

  getTitle: ->
    'Hello, World'
