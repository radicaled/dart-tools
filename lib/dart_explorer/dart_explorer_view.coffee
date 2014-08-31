{ScrollView} = require 'atom'

module.exports =
class DartExplorerView extends ScrollView
  @content: ->
    @div class: 'native-key-bindings dart-explorer', tabindex: -1, =>
      @h2 'Hello, World!'
      @ol outlet: 'list'

  initialize: (@project, @api) =>
    @handleEvents()
    promise = @api.search.findTopLevelDeclarations 'String'
    promise.then (obj) =>
      console.log 'I got this:', obj
      @setItems(obj.params.results)

  getTitle: ->
    'Hello, World'

  handleEvents: ->
    @subscribe this, 'core:move-up', => @scrollUp()
    @subscribe this, 'core:move-down', => @scrollDown()

  setItems: (items) =>
    @list.empty()
    for item in items
      for path in item.path # ???

        @list.append "
        <li>
          <h2>#{path.name} - #{path.kind}</h2>
          <p>#{path.location.file}</p>
        </li>
        "
