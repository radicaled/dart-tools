{ScrollView, EditorView} = require 'atom'

Q = require 'q'
_ = require 'lodash'

module.exports =
class DartExplorerView extends ScrollView
  @content: ->
    @div class: 'native-key-bindings dart-explorer', tabindex: -1, =>
      @header =>
        @h2 class: 'text-highlight', =>
          @text 'Dart Explorer'
          @span
            class: 'loading loading-spinner-small inline-block off'
            outlet: 'loadingSpinner'
      @subview 'filterEditorView', new EditorView(mini: true)
      @ol outlet: 'list'

  initialize: (@project, @api) =>
    @handleEvents()
    @filterEditorView.focus()

  getTitle: =>
    'Dart Explorer'

  handleEvents: ->
    @subscribe this, 'core:move-up', => @scrollUp()
    @subscribe this, 'core:move-down', => @scrollDown()

    promise = Q.fcall -> true

    editor = @filterEditorView.getEditor()
    @subscribe editor, 'contents-modified', =>
      @loadingSpinner.removeClass('off')

      text = editor.getText()
      promise = promise.then => @api.search.findTopLevelDeclarations text
      promise = promise.then (obj) => @setItems(obj.params.results)


  setItems: (items) =>
    @loadingSpinner.addClass('off')
    @list.empty()
    for item in items
      for path in item.path # ???

        @list.append "
        <li class='text-highlight'>
          <h2>#{path.name} - #{path.kind}</h2>
          <p class='text-info'>#{path.location.file}</p>
        </li>
        "
