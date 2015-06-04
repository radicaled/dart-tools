Utils = require './utils'
DartTools = require './dart-tools'
AutoCompletePlusProvider = require './autocomplete/provider'
module.exports =

  # Wizardry
  config:
    pubGetOnSave:
      type: 'boolean'
      default: true
    # automaticFormat:
    #   type: 'boolean'
    #   default: false
    formatOnSave:
      type: 'boolean'
      default: true
    dartSdkLocation:
      type: 'string'
      default: ''

  # Provider for `autocomplete-plus`
  provideAutocompleter: ->
    AutoCompletePlusProvider

  activate: (state) ->
    @dartTools = new DartTools()
    @dartTools.waitForDartSources()
    @dartTools.registerGlobalCommands()

    return unless Utils.isDartProject()
    @dartTools.boot()

  deactivate: ->
    @dartTools.dispose()
