
module.exports =
class SearchAPI
  constructor: (@api) ->

  findTopLevelDeclarations: (pattern) =>
    @api.perform 'search.findTopLevelDeclarations',
      {pattern}
