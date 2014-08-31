{ScrollView, EditorView} = require 'atom'

Q = require 'q'
_ = require 'lodash'

module.exports =
class DartExplorerView extends ScrollView
  @content: ->
    @div class: 'native-key-bindings dart-explorer', tabindex: -1, =>
      @h2 class: 'text-highlight', =>
        @text 'Dart Explorer'
      @subview 'filterEditorView', new EditorView(mini: true)
      @ol outlet: 'list'

  initialize: (@project, @api) =>
    @handleEvents()

  getTitle: ->
    'Hello, World'

  handleEvents: ->
    @subscribe this, 'core:move-up', => @scrollUp()
    @subscribe this, 'core:move-down', => @scrollDown()

    promise = Q.fcall -> true

    editor = @filterEditorView.getEditor()
    @subscribe editor, 'contents-modified', =>
      text = editor.getText()
      promise = promise.then => @api.search.findTopLevelDeclarations 'String'
      promise = promise.then (obj) => @setItems(obj.params.results)


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
