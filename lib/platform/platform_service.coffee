class PlatformService
  @windowsCmdMap =
    pub: 'pub.bat'
    dart: 'dart.exe'

  @getExecutable: (cmd) =>
    isWin = /^win/.test(process.platform)
    return cmd unless isWin
    windowsCmd = @windowsCmdMap[cmd]
    return windowsCmd or cmd

module.exports = PlatformService
