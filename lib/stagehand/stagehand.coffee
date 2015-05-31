spawn = require('child_process').spawn
SdkService = require '../sdk/sdk_service'
Picker = require '../ui/picker'
path = require 'path'

# Stagehand support
class Stagehand
  @activate: =>
    return new Promise (resolve, reject) =>
      cmd  = SdkService.getCommandPath 'pub'
      args = ['global', 'activate', 'stagehand']
      errors = ''

      process = spawn cmd, args
      process.stderr.on 'data', (data) =>
        errors = errors + data.toString()
      process.on 'exit', (code) =>
        if code == 0
          resolve()
        else
          reject(errors)

  @getProjectTemplates: =>
    return new Promise (resolve, reject) =>
      cmd  = SdkService.getCommandPath 'pub'
      args = ['global', 'run', 'stagehand', '--machine']
      errors = ''
      json = ''

      process = spawn cmd, args
      process.stdout.on 'data', (data) =>
        json = json + data.toString()
      process.stderr.on 'data', (data) =>
        errors = errors + data.toString()
      process.on 'exit', (code) =>
        if code == 0
          resolve(JSON.parse(json))
        else
          reject(errors)

  @showProjectTemplates: =>
    picker = new Picker
    @getProjectTemplates().then (projectTemplates) =>
      items = projectTemplates.map (pt) =>
        {item: pt, displayName: pt.label, description: pt.description}

      return picker.selectFrom(items)

  @generate: (projectTemplate) =>
    picker = new Picker
    projectPaths  = atom.project.getPaths()
    generateProject = (projectPath) =>
      atom.notifications.addInfo "[dart-tools] Generating #{projectTemplate.label}."

      cmd  = SdkService.getCommandPath 'pub'
      args = ['global', 'run', 'stagehand', projectTemplate.name]
      errors = ''
      output = ''

      process = spawn cmd, args,
        cwd: projectPath
      process.stdout.on 'data', (data) =>
        output = output + data.toString()
      process.stderr.on 'data', (data) =>
        errors = errors + data.toString()
      process.on 'exit', (code) =>
        if code == 0
          atom.notifications.addInfo "[dart-tools] Generated #{projectTemplate.label}!"
        else
          atom.notifications.addError "[dart-tools] Failed to generate #{projectTemplate.label}!",
            detail: errors || output

    if projectPaths.length is 0
      atom.notifications.addError "[dart-tools] Cannot run Stagehand without a project directory open."
    else if projectPaths.length is 1
      generateProject(projectPaths[0])
    else
      items = (p for p in projectPaths).map (p) ->
        {item: p, displayName: path.basename(p)}
      picker.selectFrom(items).then(
        (selectedProjectPath) => generateProject(selectedProjectPath)
        () => 1
      )


module.exports = Stagehand
