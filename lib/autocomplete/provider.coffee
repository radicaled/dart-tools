{filter} = require 'fuzzaldrin'
{_} = require 'lodash'
Utils = require '../utils'

AutoCompletePlusProvider =
  selector: '.source.dart'
  disableForSelector: '.source.dart .comment'

  inclusionPriority: 1
  excludeLowerPriority: true

  # Our analysis API service object
  analysisApi: null

  typeMap:
    class_type_alias: 'class'
    setter: 'property'
    getter: 'property'
    local_variable: 'variable'
    function_type_alias: 'function'
    enum: 'constant'
    enum_constant: 'constant'
    # The following don't map well, I think
    # top_level_variable:


  # Required: Return a promise, an array of suggestions, or null.
  getSuggestions: ({editor, bufferPosition, scopeDescriptor, prefix}) ->
    new Promise (resolve) =>
      if @analysisApi
        path = editor.getPath()
        offset = editor.buffer.characterIndexForPosition(bufferPosition)
        return unless Utils.isCompatible(editor)

        @analysisApi.updateFile path, editor.getText()
        @analysisApi.completion.getSuggestions(path, offset)
          .then (autocompleteInfo) =>
            items = []
            results = autocompleteInfo.params.results
            sortedResults = _.chain(results)
              .where((i) -> i.relevance > 500) # 500 = garbage tier
              .sort( (a, b) -> a.relevance - b.relevance)
              .value()
            # Side-step the analzyer's sad, sad relevance scores.
            # Both "XmlDocument" and "XmlName" have the same relevance score
            # for the fragment "XmlDocumen"
            if prefix isnt "."
              sortedResults = filter(results, prefix, {key: 'completion'})

            for result in sortedResults
              items.push
                text: result.completion
                leftLabel: result.returnType
                rightLabel: result.element?.kind or result.kind
                type: @mapType(result)
                description: result.docSummary

            resolve(items)

  mapType: (result) ->
    kind = (result.element?.kind or result.kind or '').toLowerCase()
    @typeMap[kind] or kind

  # (optional): called _after_ the suggestion `replacementPrefix` is replaced
  # by the suggestion `text` in the buffer
  onDidInsertSuggestion: ({editor, triggerPosition, suggestion}) ->

  # (optional): called when your provider needs to be cleaned up. Unsubscribe
  # from things, kill any processes, etc.
  dispose: ->


module.exports = AutoCompletePlusProvider
