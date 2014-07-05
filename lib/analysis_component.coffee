AnalysisServer = require './analysis_server'
chokidar = require 'chokidar'
spawn = require('child_process').spawn
extname = require('path').extname

module.exports =
class AnalysisComponent
  subscriptions: []
  enable: =>
    @subscriptions.push atom.project.on 'path-changed', @watchDartProject
    @watchDartProject()

  disable: =>
    @cleanup()

  isDartProject: =>
    pubspec = atom.project.getRootDirectory().getFile('pubspec.yaml')
    pubspec.exists()

  watchDartProject: =>
    @cleanup()

    return unless @isDartProject()

    rootPath = atom.project.getPath()
    @analysisServer = new AnalysisServer(rootPath)
    @analysisServer.start atom.project.getPath()

    @watcher = chokidar.watch rootPath, ignored: /packages/, ignoreInitial: true
    @watcher.on 'all', (event, pathname) =>
      if extname(pathname) == '.dart'
        @analysisServer.check(pathname)

  cleanup: =>
    subscription.off() for subscription in @subscriptions
    @subscriptions = []
    @watcher?.close()
    @analysisServer?.stop()
