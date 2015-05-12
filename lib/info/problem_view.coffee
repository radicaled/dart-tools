url = require 'url'
rivets = require 'rivets'
Template = require '../templates/template'

class ProblemView
  @uri: 'dart-tools://problem-view'

  @register: (@errors) =>
    pve = document.registerElement 'dart-tools-problem-view',
      prototype: ProblemViewElement.prototype

    atom.views.addViewProvider
      modelConstructor: ProblemView
      viewConstructor: pve

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
        @problemList = @problemList.concat(v)
    updateErrors()
    @errors.onChange updateErrors


  createdCallback: ->
    rivets.formatters.lowerCase = (s) -> if s then s.toLowerCase() else s
    element = Template.get('info/problem_view.html')
    @view = rivets.bind(element, {it: this})
    @appendChild element


  getTitle: ->
    "Dart: Problems"

  navigateToProblem: (event) =>
    target = event.target;
    file = target.getAttribute('data-file')
    line = target.getAttribute('data-line') - 1
    col  = target.getAttribute('data-col') - 1

    atom.workspace.open file,
      initialLine: line
      initialColumn: col

module.exports = ProblemView
