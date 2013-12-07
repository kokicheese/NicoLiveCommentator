#
#
#

require('better-require')()

_ = require 'underscore'
fs = require 'fs'
path = require 'path'
Director = require './cake-director.coffee'

class NlcDirector extends Director
  constructor: ->
    super
    @cmdSet
      manifest: @manifest.bind(@)

  manifest: (data)->
    @buildTasks.push (next)=>
      _path = path.join @out, 'manifest.json'
      data = JSON.stringify data
      fs.writeFile _path, data, (err)->
        next(err)
        
module.exports = exports = NlcDirector
