fs    = require 'fs'
path  = require 'path'

class Template
  @get: (template) ->
    # Note: assumes that `Template` is one directory removed from lib,
    # and that all templates live in lib/ somewhere.
    current = __dirname

    html = fs.readFileSync path.join(current, '..', template), encoding: 'utf-8'
    wrapper= document.createElement('div')
    wrapper.innerHTML = html
    wrapper.firstChild

module.exports = Template
