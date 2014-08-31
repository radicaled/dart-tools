{Model} = require 'theorist'

module.exports =
class SearchAPI
  constructor: (@api) ->

  findTopLevelDeclarations: (pattern) =>
    @api.perform 'search.findTopLevelDeclarations',
      {pattern}

  findMemberDeclarations: (name) =>
    @api.perform 'search.findMemberDeclarations',
      {name}
