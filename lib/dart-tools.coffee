DartToolsView = require './dart-tools-view'
chokidar = require 'chokidar'
spawn = require('child_process').spawn
extname = require('path').extname

module.exports =
  # spooky ( ͡° ͜ʖ ͡°)
  dartToolsView: null
  watcher: null

  activate: (state) ->
    # @dartToolsView = new DartToolsView(state.dartToolsViewState)
    analyzeProject = =>
      "dartanalyzer --package-root=#{atom.project.getPath()}"

    analyzeFile = (file) =>
      args = [
        "-p",
        atom.project.getPath(),
        file
      ]
      cmd = "dartanalyzer"
      console.log "running #{cmd} ", args
      ps = spawn cmd, args
      ps.stdout.on 'data', (data) =>
        console.log 'Found ' + data
        # process data in the form of:
        # INFO|HINT|USE_OF_VOID_RESULT|/home/arron/Projects/dart-tools/../citadel/lib/game/hands.dart|22|52|6|The result of 'addAll' is being used, even though it is declared to be 'void'
        # when passing in "--format=machine"

    checkForDart = =>
      pubspec = atom.project.getRootDirectory().getFile('pubspec.yaml')
      @watcher?.close()
      if pubspec.exists()
        rootPath = atom.project.getPath()
        @watcher = chokidar.watch rootPath, ignored: /packages/, ignoreInitial: true
        @watcher.on 'all', (event, pathname) =>
          if extname(pathname) == '.dart'
            analyzeFile(pathname)


    atom.project.on 'path-changed', checkForDart
    checkForDart() # project was already loaded by the time we're loaded.

  deactivate: ->
    @watcher?.close()
    # @dartToolsView.destroy()

  serialize: ->
    # dartToolsViewState: @dartToolsView.serialize()
