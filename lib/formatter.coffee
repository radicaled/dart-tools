{_} = require 'lodash'
Utils = require './utils'

module.exports =
class Formatter
  @formatCode: (fullPath) =>
    @format fullPath

  @format: (fullPath, options) =>
    Utils.whenDartSdkFound =>
      spawn = require('child_process').spawn

      args = _.flatten([
        '-w',
        options || [],
        fullPath
      ])

      spawn "dartfmt", args
