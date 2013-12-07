#
#

require('better-require')()

NlcDirector = require('./lib/nlc_director.coffee')
director = new NlcDirector

director.out = './src/dev/'

#submodules
_([
  './bootstrap/dist/js/bootstrap.min.js'
  ]).each (f)->
    mv f, director.out

#src
build './src/background/'

build './src/app/'

build './src/init/'

build './src/lib/'

manifest require('./src/manifest.yml')
