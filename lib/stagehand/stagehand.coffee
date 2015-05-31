spawn = require('child_process').spawn
SdkService = require '../sdk/sdk_service'
Picker = require '../ui/picker'

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
        {item: pt, displayName: pt.label}

      promise = picker.selectFrom(items).then(
        (selectedItem) =>
          atom.notifications.addInfo("Picked #{selectedItem.label}")
        => 1
      )
      promise.then()

module.exports = Stagehand
