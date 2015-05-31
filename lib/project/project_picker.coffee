rivets = require 'rivets'
Template = require '../templates/template'

class ProjectPicker
  launch: =>
    @view = new View()
    @view.shouldShow = true

class View
  shouldShow: false

  constructor: ->
    element = Template.get('project/project_picker.html')
    atom.workspace.addTopPanel(item: element)
    atom.commands.add 'atom-workspace', 'core:cancel', =>
      @shouldShow = false

    @view = rivets.bind(element, {it: this})

    @listen()

  listen: =>

module.exports = ProjectPicker
