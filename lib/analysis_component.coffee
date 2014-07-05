AnalysisServer = require './analysis_server'
AnalysisView = require './views/analysis_view'

chokidar = require 'chokidar'
spawn = require('child_process').spawn
extname = require('path').extname

module.exports =
class AnalysisComponent
  subscriptions: []
  analysisStatusView: null
  analysisView: null

  enable: =>
    @subscriptions.push atom.project.on 'path-changed', @watchDartProject
    @watchDartProject()
    @createAnalysisStatusView()
    @createAnalysisView()

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
    @analysisStatusView?.detach()

  createAnalysisStatusView: =>
    return unless @isDartProject()
    atom.packages.once 'activated', =>
      {statusBar} = atom.workspaceView
      if statusBar?
        AnalysisStatusView = require './views/analysis_status_view'
        @analysisStatusView = new AnalysisStatusView(statusBar)
        @analysisStatusView.attach()

  createAnalysisView: =>
    @analysisView = new AnalysisView()

  showProblems: =>
    console.log 'showing problems'
