
module.exports =
class CompletionAPI
  constructor: (@api) ->

  getSuggestions: (file, offset) =>
    @api.perform 'completion.getSuggestions',
      file: file,
      offset: offset
