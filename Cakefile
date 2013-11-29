#
#


Director = require './lib/cake-director.coffee'

class NlcDirector extends Director
  constructor: ->
    super

director = new NlcDirector

director.out = './src/dev/'

build './src/background/'

build './src/app/'

build './src/init/'

build './src/lib/utf.coffee'
