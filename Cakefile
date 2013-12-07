#
#

require('better-require')()

NlcDirector = require('./lib/nlc_director.coffee')
director = new NlcDirector

director.out = './src/dev/'

build './src/background/'

build './src/app/'

build './src/init/'

build './src/lib/utf.coffee'

manifest require('./src/manifest.yml')
