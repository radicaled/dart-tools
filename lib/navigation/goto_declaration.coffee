Picker = require '../ui/picker'

class GotoDeclaration
  constructor: (@analysisApi) ->

  displayProjectSymbols: =>
    atom.notifications.addInfo 'showing project symbols'
    editor = atom.workspace.getActiveTextEditor()
    path = editor.getPath()
    offset = 0
    length = editor.getText().length

    # @analysisApi.analysis.getNavigation path, offset, length
    @analysisApi.analysis.getLibraryDependencies().then (response) =>
      validFiles = []
      console.log 'RESULT:', response.result.packageMap
      for library in response.result.libraries
        validFiles.push(library)
      # for project, pkgs of response.result.packageMap
      #   console.log 'entering', project, 'it has', pkgs
      #   for pkg, files of pkgs
      #     for file in files
      #       validFiles.push(file) if atom.project.contains(file)
      #       # validFiles.push(file)

      @analysisApi.analysis.setSubscriptions {'NAVIGATION': validFiles}

module.exports = GotoDeclaration
