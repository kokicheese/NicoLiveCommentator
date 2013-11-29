#
#

require('better-require')()

_ = require 'underscore'
fs = require 'fs'
path = require 'path'
Director = require './lib/cake-director.coffee'

class NlcDirector extends Director
  constructor: ->
    super
    self = @
    _([
      'manifest'
      ]).each (cmd)=>
        root[cmd] = @[cmd].bind(@)

  manifest: (data)->
    @tasks.push (next)=>
      _path = path.join @out, 'manifest.json'
      data = JSON.stringify data
      fs.writeFile _path, data, (err)->
        next(err)

director = new NlcDirector

director.out = './src/dev/'

build './src/background/'

build './src/app/'

build './src/init/'

build './src/lib/utf.coffee'

manifest require('./src/manifest.yaml')
