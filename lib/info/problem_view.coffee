url = require 'url'
rivets = require 'rivets'
_ = require 'lodash'
Template = require '../templates/template'

class ProblemView
  @uri: 'dart-tools://problem-view'

  @isRegistered: (tagName) =>
    document.createElement(tagName).constructor != HTMLElement

  @register: (@errors) =>
    # Github issue #26: somehow module is being reloaded,
    # but document isn't, so the dart-tools-problem-view element is already
    # registered. User might be toggling dart-tools on/off via settings panel?
    pve = if @isRegistered('dart-tools-problem-view')
      document.createElement('dart-tools-problem-view').constructor
    else
      document.registerElement 'dart-tools-problem-view',
        prototype: ProblemViewElement.prototype

    atom.views.addViewProvider ProblemView, -> new pve()

    atom.workspace.addOpener (uri) =>
      try
        {protocol, host, pathname} = url.parse(uri)
      catch error
        return

      return unless protocol is 'dart-tools:'
      return unless host == 'problem-view'

      view = new pve()
      view.initialize(@errors)
      return view


class ProblemViewElement extends HTMLElement
  problemList: []
  problemCount: =>
    @problemList.length

  initialize: (@errors) =>
    updateErrors = =>
      @problemList = []
      for k,v of @errors.repository
        if v.length > 0
          @problemList = @problemList.concat
            file: k
            count: v.length
            problems: v

    updateErrors()
    @errors.onChange _.debounce(updateErrors, 250, maxWait: 1000)


  createdCallback: ->
    rivets.formatters.lowerCase = (s) -> if s then s.toLowerCase() else s
    rivets.formatters.relativePath = (s) -> atom.project.relativizePath(s)[1]

    this.innerHTML = Template.getText('info/problem_view.html')
    @view = rivets.bind(this, {it: this})

    # element = Template.get('info/problem_view.html')
    # @view = rivets.bind(element, {it: this})
    # @appendChild element


  getTitle: ->
    "Dart: Problems"

  navigateToProblem: (event) =>
    target = event.currentTarget;
    file = target.getAttribute('data-file')
    line = target.getAttribute('data-line') - 1
    col  = target.getAttribute('data-col') - 1

    atom.workspace.open file,
      initialLine: line
      initialColumn: col

  copy: =>
    view = atom.views.getView new ProblemView
    view.initialize(@errors)
    view
module.exports = ProblemView
